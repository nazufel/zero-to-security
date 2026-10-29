# Audit logs: CloudTrail

**Pillars:** ☁️ Cloud · 🪪 Identity

## Why this matters

**OWASP A09, Security Logging and Alerting Failures**, is the risk behind every incident report that says "we don't know what the attacker accessed." Without logs, you can't answer the questions that matter: what did they touch, what did they take, are they still here?

In [Module 6](../06-cloud-aws/11-cli-and-boto3.md) you found the gaps in CloudTrail's free event history: only 90 days, only management events, no record of anyone reading your data, and it lives in the same account an attacker might control. This lesson closes all four.

## Do it

1. **Create a trail** that keeps every management event, plus **data events** for the notes table and the files bucket, in a bucket you control, with tamper detection. Add `notes-app/infra/logging.tf` from the [reference copy](../06-cloud-aws/reference/notes-app/infra/logging.tf). For this lesson, you need the `alert_email` variable and the sections down to (and including) `aws_cloudtrail.main`. The alarms come in lesson 4.

   Read the trail resource:

   | Setting | Why |
   |---|---|
   | `s3_bucket_name` | Logs go to their own private, versioned, TLS-only bucket, with a policy that lets only **this trail** write |
   | `enable_log_file_validation` | CloudTrail signs a hash of every log file, so you can prove nobody edited or deleted one |
   | `is_multi_region_trail` | Records every region, including the ones you never use, which is exactly where attackers launch things |
   | `cloud_watch_logs_group_arn` | Also streams events to CloudWatch Logs, so you can search and alarm on them in minutes (lesson 4) |
   | `advanced_event_selector` | Management events, plus **data events** for exactly two resources: the notes table and the files bucket |

   > **Cost:** the first copy of management events is free. Data events are about $0.10 per 100,000, and a lab makes a few hundred. CloudWatch Logs charges for ingestion beyond the free tier, also pennies here. Still, run your end-of-session `tofu destroy`.

   Set `alert_email` to your email address in `terraform.tfvars` (it's gitignored, so your address stays out of your public repo). For the pipeline, add a repository variable `ALERT_EMAIL` in GitHub (**Settings → Secrets and variables → Actions → Variables**); the [reference workflow](../08-security-concepts/reference/notes-app.yml) passes it to OpenTofu. Then apply:

   ```bash
   cd ~/my-security-portfolio/notes-app/infra
   echo 'alert_email = "you@example.com"' > terraform.tfvars
   tofu apply
   ```

2. **Make a data event**, the kind event history missed in Module 6:

   ```bash
   aws dynamodb scan --table-name notes-notes --query Count
   ```

3. **Find it**, a few minutes later, in CloudWatch Logs:

   ```bash
   aws logs filter-log-events --log-group-name /aws/cloudtrail/notes \
     --filter-pattern '{ $.eventName = "Scan" }' --query 'events[].message' --output text \
     | jq '{eventTime, eventName, who: .userIdentity.arn, from: .sourceIPAddress, table: .resources[0].ARN}'
   ```

   ```json
   {
     "eventTime": "2026-10-29T23:01:12Z",
     "eventName": "Scan",
     "who": "arn:aws:sts::123456789012:assumed-role/...",
     "from": "198.51.100.77",
     "table": "arn:aws:dynamodb:us-east-1:123456789012:table/notes-notes"
   }
   ```

   Now "someone read every note" leaves a trace: who, when, from where.

4. **Check the logs haven't been tampered with:**

   ```bash
   TRAIL_ARN=$(aws cloudtrail describe-trails --trail-name-list notes-trail --query 'trailList[0].TrailARN' --output text)
   aws cloudtrail validate-logs --trail-arn "$TRAIL_ARN" --start-time "$(date -u -d '1 hour ago' +%Y-%m-%dT%H:%M:%SZ)"
   ```

   It checks every log file against CloudTrail's signed digests. (Digest files arrive hourly, so give it an hour after creating the trail.)

5. Commit `logging.tf`.

## Break it

Be the attacker covering their tracks. Download one log file from the trail bucket, edit it, and put it back:

```bash
BUCKET=$(aws s3 ls | awk '/notes-trail-/ {print $3}')
KEY=$(aws s3api list-objects-v2 --bucket "$BUCKET" --prefix AWSLogs --query 'Contents[?contains(Key, `/CloudTrail/`)] | [0].Key' --output text)
aws s3 cp "s3://$BUCKET/$KEY" log.json.gz
gunzip log.json.gz && sed -i 's/198.51.100/10.0.0/g' log.json && gzip log.json
aws s3 cp log.json.gz "s3://$BUCKET/$KEY"
```

You "hid" your IP address. Run `validate-logs` again (once that hour's digest exists):

```
... INVALID: hash value doesn't match
```

Caught. The attacker changed the log, but couldn't change the signed digest CloudTrail wrote alongside it. And because the bucket is versioned, the original is still there. Real teams go further: they send logs to a **separate** account that the production account can't touch at all. You'll see that design at work; it needs AWS Organizations, which this course avoids.

Clean up: `rm log.json.gz`.

## With Claude

Ask Claude Code:

```text
Read notes-app/infra/logging.tf. If an attacker got AdministratorAccess in
this account, what could they do to the audit trail, and how would I know?
Don't change anything.
```

**Check the work:** a good answer: they could `StopLogging` or `DeleteTrail` (and both of **those** calls are themselves logged, to the last moment), delete the bucket's objects (versioning helps until they delete versions), or change the event selectors. Did Claude suggest an alarm on `StopLogging`, `DeleteTrail`, and `UpdateTrail`? That's a real and common detection; you could add it as a third metric filter. Did it claim CloudTrail can't be stopped by an admin? It can.

## Check yourself

1. What does a trail give you that free event history doesn't?
   <details><summary>Answer</summary>

   Long-term storage you control, data events (like reading DynamoDB items or S3 objects), all regions, tamper detection, and streaming to CloudWatch for alarms.
   </details>

2. How does log file validation detect tampering?
   <details><summary>Answer</summary>

   CloudTrail writes signed digest files containing hashes of each log file. If a log is changed or deleted, its hash no longer matches the signed digest.
   </details>

3. Why record every region, even ones you don't use?
   <details><summary>Answer</summary>

   Attackers deliberately launch resources in unused regions, where nobody is looking. A single-region trail would miss it.
   </details>

## Go deeper

- [CloudTrail log file integrity validation](https://docs.aws.amazon.com/awscloudtrail/latest/userguide/cloudtrail-log-file-validation-intro.html)
- [OWASP A09:2025, Security Logging and Alerting Failures](https://owasp.org/Top10/2025/)
