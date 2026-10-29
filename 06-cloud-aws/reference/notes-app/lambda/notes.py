"""notes: a tiny notes API, run by AWS Lambda behind API Gateway."""

import hmac
import json
import os
import time
import uuid

import boto3

table = boto3.resource("dynamodb").Table(os.environ["TABLE_NAME"])
ssm = boto3.client("ssm")
sqs = boto3.client("sqs")

_admin_token = None


def admin_token():
    """Read the admin token from Parameter Store once, then reuse it."""
    global _admin_token
    if _admin_token is None:
        response = ssm.get_parameter(Name=os.environ["TOKEN_PARAM"], WithDecryption=True)
        _admin_token = response["Parameter"]["Value"]
    return _admin_token


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
        MessageBody=json.dumps({"event": "note_created", "id": note["id"]}),
    )
    return respond(201, note)


def delete_note(event):
    given = event.get("headers", {}).get("x-admin-token", "")
    if not hmac.compare_digest(given, admin_token()):
        return respond(403, {"error": "forbidden"})
    table.delete_item(Key={"id": event["pathParameters"]["id"]})
    return respond(200, {"deleted": event["pathParameters"]["id"]})


def handler(event, context):
    route = event.get("routeKey")
    if route == "GET /notes":
        return list_notes()
    if route == "POST /notes":
        return create_note(event)
    if route == "DELETE /notes/{id}":
        return delete_note(event)
    return respond(404, {"error": "not found"})
