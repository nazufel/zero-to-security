# Data: DynamoDB

**Pillars:** ☁️ Cloud · 🪪 Identity

## Why this matters

An app that forgets everything isn't much of an app. **DynamoDB** is AWS's serverless database: no server to patch, no hourly bill when it's idle, and generous free limits. It's where the notes live.

It's also where the most valuable data in any app lives, which makes one question matter more than any other: **who can read and write it?** In this lesson, the answer is "only the notes function, and only the four actions it needs."

## Do it

**Console:** open **DynamoDB → Create table** and look: a table name, a **partition key** (the unique ID for each item), and capacity settings. Don't create it.

**Code:**

1. Create `infra/dynamodb.tf`:

   ```hcl
   resource "aws_dynamodb_table" "notes" {
     name         = "${var.name}-notes"
     billing_mode = "PAY_PER_REQUEST"
     hash_key     = "id"

     attribute {
       name = "id"
       type = "S"
     }
   }
   ```

   `PAY_PER_REQUEST` means no reserved capacity: you're charged only for reads and writes, and a lab's handful stays inside the free limits. `hash_key` is the partition key: every note has a unique `id`, a string (`S`).

2. Give the function the table's name, and permission to use it. In `lambda.tf`, add to `aws_lambda_function.notes`:

   ```hcl
     environment {
       variables = {
         TABLE_NAME = aws_dynamodb_table.notes.name
       }
     }
   ```

   And add a policy to the role:

   ```hcl
   resource "aws_iam_role_policy" "notes" {
     name = "notes-app-access"
     role = aws_iam_role.notes.id

     policy = jsonencode({
       Version = "2012-10-17"
       Statement = [
         {
           Effect   = "Allow"
           Action   = ["dynamodb:GetItem", "dynamodb:PutItem", "dynamodb:DeleteItem", "dynamodb:Scan"]
           Resource = aws_dynamodb_table.notes.arn
         },
       ]
     })
   }
   ```

   Four actions, on one table. Not `dynamodb:*`, not `Resource = "*"`. That's **least privilege**, and Module 7 is all about it.

3. Replace `lambda/notes.py` with a real notes API:

   ```python
   """notes: a tiny notes API, run by AWS Lambda behind API Gateway."""

   import json
   import os
   import time
   import uuid

   import boto3

   table = boto3.resource("dynamodb").Table(os.environ["TABLE_NAME"])


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
       return respond(201, note)


   def handler(event, context):
       route = event.get("routeKey")
       if route == "GET /notes":
           return list_notes()
       if route == "POST /notes":
           return create_note(event)
       return respond(404, {"error": "not found"})
   ```

   You know every piece of this from [Module 3](../03-python/): functions, dictionaries, JSON, `try`/`except`, and **never trust input** (lesson 7). `create_note` checks the body is JSON, that `text` is a string, and that it's 1 to 500 characters, before anything touches the database. `boto3` is the AWS SDK for Python; Lambda's Python runtime includes it.

4. Add the route in `api.tf`:

   ```hcl
     for_each = toset(["GET /notes", "POST /notes"])
   ```

5. Apply and use it:

   ```bash
   tofu apply
   curl -s -X POST "$API/notes" -H 'content-type: application/json' -d '{"text": "my first real note"}'
   curl -s "$API/notes"
   ```

   ```json
   {"id": "0b7f6c1e-...", "text": "my first real note", "created": 1793314083}
   [{"id": "0b7f6c1e-...", "text": "my first real note", "created": 1793314083}]
   ```

   (If `$API` is empty, set it again: `API=$(tofu output -raw api_url)`.) Check it in the console too: **DynamoDB → Tables → notes-notes → Explore table items**.

6. Test the input checks, like an attacker would:

   ```bash
   curl -s -X POST "$API/notes" -d 'not json'
   curl -s -X POST "$API/notes" -d '{"text": ""}'
   curl -s -X POST "$API/notes" -d "{\"text\": \"$(head -c 600 /dev/zero | tr '\0' 'a')\"}"
   ```

   Three `400`s, each with a clear error. Nothing bad reached the database.

7. Commit:

   ```bash
   git add dynamodb.tf lambda.tf api.tf ../lambda/notes.py
   git commit -m "Store notes in DynamoDB"
   git push
   ```

## Break it

Take away one permission, and learn to read what happens. In `lambda.tf`, remove `"dynamodb:PutItem"` from the action list, and apply. Then try to create a note:

```bash
curl -s -i -X POST "$API/notes" -d '{"text": "will this work?"}'
```

```
HTTP/2 500
{"message":"Internal Server Error"}
```

The user sees a vague `500`, which is right: never show internal errors to users. You, the engineer, look in the logs:

```bash
aws logs tail /aws/lambda/notes-api --since 5m | grep -i denied
```

```
botocore.exceptions.ClientError: An error occurred (AccessDeniedException) when calling the PutItem operation:
User: arn:aws:sts::123456789012:assumed-role/notes-lambda/notes-api is not authorized to perform:
dynamodb:PutItem on resource: arn:aws:dynamodb:us-east-1:123456789012:table/notes-notes because no
identity-based policy allows the dynamodb:PutItem action
```

Read it slowly, because you'll read hundreds of these: **who** (`assumed-role/notes-lambda`), **what** (`dynamodb:PutItem`), **on what** (the table's ARN), and **why** ("no identity-based policy allows" it). Everything you need to fix it is in that one message. Put `PutItem` back and apply.

## With Claude

Ask Claude Code:

```text
Add a GET /notes/{id} route that returns one note. Update notes.py, api.tf,
and anything else needed. Show me the plan before you write code.
```

**Check the work:**

- Does the IAM policy need to change? (`GetItem` is already allowed. Did Claude add `dynamodb:*` "to be safe" anyway?)
- Does the code handle a note that doesn't exist with a `404`, or does it crash with a `500`?
- Does it use the ID from the path directly in the `Key`, without trusting it to be anything more than a string?
- Run `tofu plan` and read it: only the route and the function code should change.

Test it with a real ID, a fake ID, and a very long ID.

## Check yourself

1. Why give the function four specific DynamoDB actions instead of `dynamodb:*`?
   <details><summary>Answer</summary>

   Least privilege. If the function is ever tricked or compromised, it can only do those four things to one table, not delete the table or read others.
   </details>

2. An `AccessDeniedException` names `assumed-role/notes-lambda/notes-api`. What does that tell you?
   <details><summary>Answer</summary>

   The request came from the function `notes-api`, running as the role `notes-lambda`. That's the role whose policy needs checking.
   </details>

3. Why does the API return a generic `500` instead of the real error?
   <details><summary>Answer</summary>

   Internal errors can reveal how the system works, like table names, account IDs, and code paths. Users get a generic message; engineers read the logs.
   </details>

## Go deeper

- [DynamoDB core components](https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/HowItWorks.CoreComponents.html): tables, items, and keys.
