"""audit: log one line per event from the notes queue."""

import json


def handler(event, context):
    for record in event["Records"]:
        message = json.loads(record["body"])
        print(json.dumps({"audit": message, "message_id": record["messageId"]}))
