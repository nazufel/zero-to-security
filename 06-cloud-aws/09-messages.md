# Messages: SQS

**Pillars:** ☁️ Cloud

## Why this matters

Not everything should happen while a user waits. Sending an email, resizing an image, writing an audit record: the app can drop a **message** on a **queue** and answer the user right away, while another piece of code picks the message up and does the work. If that worker is slow, or down for a minute, nothing is lost. The message waits.

**SQS** (Simple Queue Service) is AWS's queue. The notes app will use it to keep an audit trail: every new note sends a message, and a separate function records it.

## Do it

**Console:** open **SQS → Create queue** and look at the settings: standard vs. FIFO, visibility timeout, message retention, encryption, and a **dead-letter queue**. Don't create it.

**Code:**

1. Create `lambda/audit.py`, the worker:

   ```python
   """audit: log one line per event from the notes queue."""

   import json


   def handler(event, context):
       for record in event["Records"]:
           message = json.loads(record["body"])
           print(json.dumps({"audit": message, "message_id": record["messageId"]}))
   ```

   Lambda delivers queue messages in batches, as `event["Records"]`. Anything a function prints goes to its CloudWatch log.

2. Create `infra/sqs.tf`:

   ```hcl
   resource "aws_sqs_queue" "events" {
     name                      = "${var.name}-events"
     message_retention_seconds = 86400
     sqs_managed_sse_enabled   = true
   }

   data "archive_file" "audit" {
     type        = "zip"
     source_file = "${path.module}/../lambda/audit.py"
     output_path = "${path.module}/build/audit.zip"
   }

   resource "aws_iam_role" "audit" {
     name = "${var.name}-audit"

     assume_role_policy = jsonencode({
       Version = "2012-10-17"
       Statement = [{
         Effect    = "Allow"
         Principal = { Service = "lambda.amazonaws.com" }
         Action    = "sts:AssumeRole"
       }]
     })
   }

   resource "aws_iam_role_policy_attachment" "audit_logs" {
     role       = aws_iam_role.audit.name
     policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
   }

   resource "aws_iam_role_policy" "audit" {
     name = "read-events-queue"
     role = aws_iam_role.audit.id

     policy = jsonencode({
       Version = "2012-10-17"
       Statement = [{
         Effect   = "Allow"
         Action   = ["sqs:ReceiveMessage", "sqs:DeleteMessage", "sqs:GetQueueAttributes"]
         Resource = aws_sqs_queue.events.arn
       }]
     })
   }

   resource "aws_cloudwatch_log_group" "audit" {
     name              = "/aws/lambda/${var.name}-audit"
     retention_in_days = 14
   }

   resource "aws_lambda_function" "audit" {
     function_name    = "${var.name}-audit"
     role             = aws_iam_role.audit.arn
     runtime          = "python3.14"
     handler          = "audit.handler"
     filename         = data.archive_file.audit.output_path
     source_code_hash = data.archive_file.audit.output_base64sha256

     depends_on = [aws_cloudwatch_log_group.audit]
   }

   resource "aws_lambda_event_source_mapping" "audit" {
     event_source_arn = aws_sqs_queue.events.arn
     function_name    = aws_lambda_function.audit.arn
     batch_size       = 10
   }
   ```

   The pattern should feel familiar by now: a function, its own role with only what it needs (read and delete from **this** queue), and a log group. The new piece is the **event source mapping**, which tells Lambda to poll the queue and call `audit` with each batch. Messages are kept for one day (86,400 seconds) and encrypted at rest.

   Notice there are now **two** roles. The API function can send to the queue but not read it; the audit function can read it but not touch the database. If either one is compromised, the attacker gets only that role's small slice.

3. Let the notes function send messages. In `lambda.tf`, add to the policy:

   ```hcl
         {
           Effect   = "Allow"
           Action   = "sqs:SendMessage"
           Resource = aws_sqs_queue.events.arn
         },
   ```

   And to the environment:

   ```hcl
         QUEUE_URL   = aws_sqs_queue.events.url
   ```

4. In `notes.py`, add a client near the others:

   ```python
   sqs = boto3.client("sqs")
   ```

   And in `create_note`, after `table.put_item(Item=note)`:

   ```python
       sqs.send_message(
           QueueUrl=os.environ["QUEUE_URL"],
           MessageBody=json.dumps({"event": "note_created", "id": note["id"]}),
       )
   ```

5. Apply, create a note, and watch the audit trail:

   ```bash
   tofu apply
   curl -s -X POST "$API/notes" -d '{"text": "audit me"}'
   sleep 10
   aws logs tail /aws/lambda/notes-audit --since 5m
   ```

   ```
   {"audit": {"event": "note_created", "id": "..."}, "message_id": "..."}
   ```

   The user got an answer right away. The audit happened a moment later, in a different function, with a different role.

6. Commit:

   ```bash
   git add sqs.tf lambda.tf ../lambda/audit.py ../lambda/notes.py
   git commit -m "Add an audit queue and worker"
   git push
   ```

## Break it

Send the worker a message it can't handle, a **poison message**:

```bash
QUEUE=$(aws sqs get-queue-url --queue-name notes-events --query QueueUrl --output text)
aws sqs send-message --queue-url "$QUEUE" --message-body "this is not json"
```

Wait a couple of minutes, then:

```bash
aws logs tail /aws/lambda/notes-audit --since 5m | grep -c JSONDecodeError
```

The count keeps going up. `json.loads` fails, so Lambda reports the batch as failed, the message goes back on the queue, and it's retried. Again and again, for the full day the queue keeps messages. Every retry is a function run. A poison message can cost money, fill your logs, and block good messages in the same batch.

The real fix is a **dead-letter queue**: after a few failed tries, SQS moves the message aside for a human to look at. For now, clear it out:

```bash
aws sqs purge-queue --queue-url "$QUEUE"
```

Your own messages came from your own code, so this was harmless. Real queues get messages from other systems, and sometimes from attackers. **Never trust input** applies to queues too.

## With Claude

Ask Claude Code:

```text
Add a dead-letter queue to sqs.tf so that messages the audit function fails
on three times are moved aside instead of retried forever. Also make audit.py
skip a bad message without failing the whole batch. Plan first.
```

**Check the work:**

- Read `tofu plan`. A new queue, and a `redrive_policy` on the events queue with `maxReceiveCount = 3`?
- Does the audit role need new permissions? (No: SQS moves the message itself.) Did Claude add `sqs:*` anyway?
- In `audit.py`, does a bad message get **logged** when it's skipped, or silently dropped? Silently dropping is how you lose evidence ([Module 3, lesson 7](../03-python/07-never-trust-input.md)).
- Send the poison message again. Does it end up in the dead-letter queue (`aws sqs get-queue-attributes --attribute-names ApproximateNumberOfMessages`) instead of looping?

> **SNS** is the other messaging service you'll hear about. A queue (SQS) holds messages for **one** consumer to work through. A topic (SNS) **broadcasts** each message to many subscribers at once, like email, SMS, or several queues. You'll use SNS in Module 9 to send alarm emails.

## Check yourself

1. Why use a queue instead of calling the audit code directly from the API function?
   <details><summary>Answer</summary>

   The user doesn't wait for it, and if the audit worker is slow or failing, messages wait in the queue instead of being lost or breaking the API.
   </details>

2. What's a poison message, and what stops it from looping forever?
   <details><summary>Answer</summary>

   A message the worker can never process successfully. A dead-letter queue moves it aside after a set number of failed tries.
   </details>

3. Why does each function have its own role?
   <details><summary>Answer</summary>

   Least privilege. Each gets only what its job needs, so compromising one gives an attacker a much smaller slice of the account.
   </details>

## Go deeper

- [SQS dead-letter queues](https://docs.aws.amazon.com/AWSSimpleQueueService/latest/SQSDeveloperGuide/sqs-dead-letter-queues.html): how redrive works.
