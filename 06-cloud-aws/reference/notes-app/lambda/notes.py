"""notes: a tiny notes API, run by AWS Lambda behind API Gateway."""

import json
import os
import time
import uuid

import boto3

table = boto3.resource("dynamodb").Table(os.environ["TABLE_NAME"])
sqs = boto3.client("sqs")


def respond(status, body):
    # DynamoDB returns numbers as Decimal, which json can't handle on its own
    return {
        "statusCode": status,
        "headers": {"content-type": "application/json"},
        "body": json.dumps(body, default=int),
    }


def list_notes():
    notes = table.scan(Limit=100).get("Items", [])
    return respond(200, sorted(notes, key=lambda n: n["created"], reverse=True))


def request_id(event):
    """API Gateway's ID for this request, so one request can be followed across every log."""
    return event.get("requestContext", {}).get("requestId", "unknown")


def create_note(event):
    try:
        text = json.loads(event.get("body") or "{}").get("text")
    except (json.JSONDecodeError, AttributeError):
        return respond(400, {"error": "body must be a JSON object"})
    if not isinstance(text, str) or not 1 <= len(text) <= 500:
        return respond(400, {"error": "text must be 1 to 500 characters"})

    note = {"id": str(uuid.uuid4()), "text": text, "created": int(time.time())}
    table.put_item(Item=note)
    sqs.send_message(
        QueueUrl=os.environ["QUEUE_URL"],
        MessageBody=json.dumps({"event": "note_created", "id": note["id"], "requestId": request_id(event)}),
    )
    return respond(201, note)


def delete_note(event):
    # API Gateway only lets signed (AWS_IAM) requests reach this route. Check anyway:
    # if the route is ever misconfigured, fail closed instead of open.
    caller = event.get("requestContext", {}).get("authorizer", {}).get("iam", {}).get("userArn")
    if not caller:
        return respond(403, {"error": "forbidden"})
    note_id = event["pathParameters"]["id"]
    table.delete_item(Key={"id": note_id})
    print(json.dumps({"deleted": note_id, "by": caller}))
    return respond(200, {"deleted": note_id})


def handler(event, context):
    route = event.get("routeKey")
    print(json.dumps({"requestId": request_id(event), "route": route}))
    if route == "GET /notes":
        return list_notes()
    if route == "POST /notes":
        return create_note(event)
    if route == "DELETE /notes/{id}":
        return delete_note(event)
    return respond(404, {"error": "not found"})
