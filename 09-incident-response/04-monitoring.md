# Monitoring: logs, metrics, and alarms

**Pillars:** ☁️ Cloud · 🪪 Identity

## Why this matters

A log nobody reads is a diary, not a defense. The time between an attacker getting in and someone noticing is called **dwell time**, and for years industry reports have measured it in days or weeks. Most of that is time when the evidence was already in a log, waiting.

**Monitoring** turns logs into numbers (**metrics**) and numbers into **alarms** that reach a human. In this lesson you'll build two alarms that email you: one for the app breaking, and one for someone probing your account with stolen credentials.

## Do it

1. **Add the alerting pieces** from the rest of [`logging.tf`](../06-cloud-aws/reference/notes-app/infra/logging.tf): the SNS topic and email subscription, both metric filters and alarms, and the API access log group. Then add access logging to the API's stage in `api.tf`:

   ```hcl
     access_log_settings {
       destination_arn = aws_cloudwatch_log_group.api_access.arn
       format = jsonencode({
         requestId = "$context.requestId"
         time      = "$context.requestTime"
         ip        = "$context.identity.sourceIp"
         caller    = "$context.identity.userArn"
         route     = "$context.routeKey"
         status    = "$context.status"
         userAgent = "$context.identity.userAgent"
       })
     }
   ```

   One JSON line per request: who, from where, what, and the result. That's the web-server access log from [Module 4](../04-networking/06-http.md), in the cloud.

2. **Read the security alarm** before you apply it:

   ```hcl
   resource "aws_cloudwatch_log_metric_filter" "access_denied" {
     name           = "access-denied"
     log_group_name = aws_cloudwatch_log_group.trail.name
     pattern        = "{ ($.errorCode = \"AccessDenied*\") || ($.errorCode = \"*UnauthorizedOperation\") }"
     ...
   ```

   A **metric filter** watches the CloudTrail log group and counts every event whose `errorCode` is a permission denial. The **alarm** fires when that count reaches 5 in 5 minutes, and sends to the SNS topic, which emails you. Legitimate users and services rarely hit five denials in five minutes; someone exploring with a stolen key almost always does.

3. Apply, then **confirm the subscription**: AWS emails you a link. Click it, or no alarm will ever reach you. (Check spam.)

   ```bash
   tofu apply
   aws sns list-subscriptions-by-topic --topic-arn "$(aws sns list-topics --query 'Topics[?contains(TopicArn, `notes-alerts`)].TopicArn' --output text)" \
     --query 'Subscriptions[].SubscriptionArn'
   ```

   It should show a real ARN, not `PendingConfirmation`.

4. **Look at the alarms' state:**

   ```bash
   aws cloudwatch describe-alarms --alarm-name-prefix notes- --query 'MetricAlarms[].[AlarmName,StateValue]' --output table
   ```

   `OK` (or `INSUFFICIENT_DATA` until there's some). Commit `logging.tf` and `api.tf`.

## Break it

**Trigger the security alarm, on purpose.** Claude's view-only role is a perfect "attacker": a real identity that's denied lots of things. Make six denied calls:

```bash
for cmd in "iam create-user --user-name x" "s3api create-bucket --bucket x-$RANDOM" "dynamodb scan --table-name notes-notes" \
           "ssm get-parameters-by-path --path / --with-decryption" "lambda delete-function --function-name notes-api" "iam create-access-key --user-name admin"; do
  aws $cmd --profile claude > /dev/null 2>&1 || echo "denied: $cmd"
done
```

Wait. CloudTrail takes a few minutes to reach CloudWatch Logs, and the alarm checks every 5 minutes. Within about 15 minutes, you get an email:

```
ALARM: "notes-access-denied-burst" in US East (N. Virginia)
Reason for State Change: Threshold Crossed: 1 datapoint [6.0] was greater than or equal to the threshold (5.0).
```

Note the delay: about 15 minutes from attack to email. That's your **detection time** for this alarm. Write it down. In an incident, it means the attacker had that long before anyone knew, and it's why alarms are one layer, not the whole defense.

Then trigger the other alarm: remove `dynamodb:Scan` from the notes role (like [Module 6](../06-cloud-aws/07-data.md)), apply, and refresh the site three times. `notes-api-errors` fires. Put the permission back.

## With Claude

Ask Claude Code:

```text
Read logging.tf. Suggest three more CloudWatch metric filters on the
CloudTrail log group that would catch real attack behavior in this account.
For each: the filter pattern, a threshold, and what attack it detects.
Write them in OpenTofu, but don't apply.
```

**Check the work:** good candidates include `StopLogging`/`DeleteTrail` (covering tracks), `ConsoleLogin` without MFA, root user activity, and `CreateAccessKey` (persistence). For each one:

- Test the **pattern** before trusting it: `aws logs filter-log-events --log-group-name /aws/cloudtrail/notes --filter-pattern '<pattern>'` on real logs. A filter with a typo matches nothing, silently, forever.
- Is the threshold sensible? A root-user alarm should fire on **1**.
- Add the ones that pass to `logging.tf`.

## Check yourself

1. What's the chain from a log line to an email?
   <details><summary>Answer</summary>

   Log event → metric filter (counts matching events) → metric → alarm (threshold over a period) → SNS topic → email subscription.
   </details>

2. Why alarm on a burst of `AccessDenied` errors?
   <details><summary>Answer</summary>

   Normal users and services rarely hit many denials quickly. Someone exploring what a stolen credential can do almost always does.
   </details>

3. You set up an alarm but never got the email. What do you check first?
   <details><summary>Answer</summary>

   Whether the email subscription was confirmed. An unconfirmed SNS subscription delivers nothing.
   </details>

## Go deeper

- [CloudWatch metric filter syntax](https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/FilterAndPatternSyntax.html)
- [CIS AWS Foundations Benchmark](https://www.cisecurity.org/benchmark/amazon_web_services): includes a list of CloudTrail alarms every account should have (free with registration).
