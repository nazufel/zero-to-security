# Traces: following one request

**Pillars:** ☁️ Cloud

## Why this matters

One click in the notes app touches CloudFront, API Gateway, the notes function, DynamoDB, the queue, and the audit function, each writing its own log in its own place. When something goes wrong, "find the logs" turns into "find which of a thousand lines in six places belong to **this** request."

Two tools solve it. A **correlation ID**: one ID, passed along and logged at every step, so you can search for it everywhere. And **tracing**: AWS X-Ray records each step's timing as one connected picture. Together, they let you follow a single request end to end, which in an incident is how you answer "what exactly did this request do?"

## Do it

1. **Pass one ID through the app.** API Gateway gives every request an ID. Log it in the notes function, and carry it into the queue message. In `lambda/notes.py`, add:

   ```python
   def request_id(event):
       """API Gateway's ID for this request, so one request can be followed across every log."""
       return event.get("requestContext", {}).get("requestId", "unknown")
   ```

   At the top of `handler`, after `route = ...`:

   ```python
       print(json.dumps({"requestId": request_id(event), "route": route}))
   ```

   And in `create_note`, add it to the message:

   ```python
           MessageBody=json.dumps({"event": "note_created", "id": note["id"], "requestId": request_id(event)}),
   ```

   The audit function already prints the whole message, so the ID reaches it automatically.

2. **Turn on X-Ray tracing** for both functions. In `lambda.tf` (and the same in `sqs.tf` for the audit function), add to the function:

   ```hcl
     tracing_config {
       mode = "Active"
     }
   ```

   and give its role permission to send traces:

   ```hcl
   resource "aws_iam_role_policy_attachment" "notes_xray" {
     role       = aws_iam_role.notes.name
     policy_arn = "arn:aws:iam::aws:policy/AWSXRayDaemonWriteAccess"
   }
   ```

   (Name the audit one `audit_xray`, on `aws_iam_role.audit`.) X-Ray's free tier covers 100,000 traces a month.

3. Apply, then make one request and capture its ID from the response headers:

   ```bash
   tofu apply
   API=$(tofu output -raw api_url)
   curl -s -D - -X POST "$API/notes" -d '{"text": "trace me"}' | grep -i apigw-requestid
   ```

   ```
   apigw-requestid: AbC1dEfGhIjKlMn=
   ```

4. **Follow it everywhere.** Wait a minute, then search every log group for that one ID:

   ```bash
   RID="AbC1dEfGhIjKlMn="
   for g in /aws/apigateway/notes-api /aws/lambda/notes-api /aws/lambda/notes-audit /aws/cloudtrail/notes; do
     echo "== $g"
     aws logs filter-log-events --log-group-name "$g" --filter-pattern "\"$RID\"" --query 'events[].message' --output text | head -3
   done
   ```

   The access log (who, from where, status), the function's log (which route), and the audit log (the queue message), all tied together. CloudTrail won't have it: it records AWS API calls, and the request ID doesn't appear there. You'd link those by time and by the function's role.

5. **See the trace.** In the console, open **CloudWatch → X-Ray traces → Traces**, find the `notes-api` trace for your request, and open it. A timeline: how long the function took to start (a "cold start," if it hadn't run recently), and how long it ran. Then find the audit function's trace a moment later.

6. Commit the code and infrastructure changes.

## Break it

Lose the thread. Remove `"requestId": request_id(event)` from the queue message, apply, make a new request, and try to find its audit log line using step 4.

You can't, not with certainty. You could guess by timestamp, but with two requests a second apart, you'd guess wrong half the time. On a busy system, it's hopeless. That's what happens at the boundaries between services when nobody passes the ID along, and it's why "we couldn't tell which request did that" shows up in real incident reports. Put it back and apply.

## With Claude

Ask Claude Code:

```text
Read notes-app/lambda/*.py. Where else should the request ID be logged or
passed so that every action a request causes can be traced? Are any of the
log lines missing information an investigator would need?
```

**Check the work:** good suggestions include logging the request ID with every error, with deletes (along with the caller's ARN, which you already log), and as an SQS message attribute instead of only in the body. Check that each suggestion doesn't log **too much**: a note's full text, or anything a user typed, in every log line can be a privacy problem, and logs are readable by more people than the database. Logging is a trade-off between evidence and exposure.

## Check yourself

1. What's a correlation ID for?
   <details><summary>Answer</summary>

   Linking every log line a single request produces, across services, so you can follow it end to end.
   </details>

2. What does X-Ray show that logs don't?
   <details><summary>Answer</summary>

   The timing of each step of a request as one connected picture: where time was spent and which step failed.
   </details>

3. Why not log a note's full text in every line, to make investigation easier?
   <details><summary>Answer</summary>

   Logs are widely readable and kept a long time. Copying user data into them spreads it to places with weaker protection than the database.
   </details>

## Go deeper

- [AWS X-Ray concepts](https://docs.aws.amazon.com/xray/latest/devguide/xray-concepts.html): segments, traces, and the service map.
