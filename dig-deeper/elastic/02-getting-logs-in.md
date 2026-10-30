# Getting logs in

**Pillars:** ☁️ Cloud

## Why this matters

A SIEM is only as good as what goes into it. Most of a SIEM engineer's work is **ingestion**: getting logs in, with the right timestamps, split into fields you can search. A log with the wrong time ends up in the wrong place on a timeline. A log that's one big blob of text can't be counted or alerted on.

You'll bring in the two logs you know best: the SSH `auth.log` from [Module 3](../../03-python/project.md), and the CloudTrail sample from [Module 6](../../06-cloud-aws/samples/cloudtrail-events.json).

## Do it

1. **Prepare CloudTrail.** Elasticsearch takes **NDJSON**: one JSON object per line. Each CloudTrail event is JSON inside a string ([Module 6](../../06-cloud-aws/11-cli-and-boto3.md)), so unwrap it. While you're at it, move the timestamps up to **now**, keeping their order and spacing, so detection rules (lesson 5) see them as recent:

   ```bash
   cd ~/my-security-portfolio/cloud
   jq -c --argjson now "$(date -u +%s)" '
     [.Events[].CloudTrailEvent | fromjson]
     | (map(.eventTime | fromdateiso8601) | max) as $max
     | .[] | .eventTime = ((.eventTime | fromdateiso8601) + ($now - $max) | todateiso8601)
   ' cloudtrail-events.json > cloudtrail-now.ndjson
   wc -l cloudtrail-now.ndjson
   head -1 cloudtrail-now.ndjson | jq .
   ```

   14 events, the newest one stamped a moment ago. Copy both files to your laptop so you can upload them through the browser:

   ```bash
   # on your laptop
   scp lab:my-security-portfolio/cloud/cloudtrail-now.ndjson lab:my-security-portfolio/logslayer/samples/auth.log .
   ```

2. **Upload CloudTrail.** In Kibana, open **Upload file** (search for it in the top bar). Drop in `cloudtrail-now.ndjson`. Kibana reads it and proposes field types. Check:

   - **Time field:** `eventTime`. This is the most important setting on the page.
   - **Index name:** `cloudtrail-lab`.

   Import, and create a **data view** when it offers to.

3. **Upload `auth.log`.** Same steps, with `auth.log`, index name `authlog-lab`. Kibana recognizes it as a log with a timestamp at the start of each line. Let it use that as the time field.

   Notice the difference. CloudTrail arrives as **structured** fields: `userIdentity.arn`, `sourceIPAddress`, `errorCode`, each searchable. `auth.log` arrives mostly as one `message` field of text. Kibana may have found the timestamp and host, but the IP address, username, and result are still buried inside the text. You'll pull them out at search time in lesson 3, the way `logslayer` does.

4. **Check the times.** Open **Discover**, pick the `cloudtrail-lab` data view, and set the time range to "Last 1 hour." All 14 events should be there. Then pick `authlog-lab` and set the time range to cover **March 14, 2026**, the date the sample log was written. Getting time ranges right is a daily SIEM skill; "no results" is very often "wrong time range."

5. Note in `elastic/notes.md`: which fields each source has, which is the time field, and what's still trapped inside text.

## Break it

Upload CloudTrail again, as `cloudtrail-wrongtime`, but this time leave the time field as whatever Kibana guesses, or pick none. Then try to find the `ci-deploy` events on a timeline in Discover.

Either they don't appear at all in time-based views, or they're stamped with the moment you uploaded them, all at once. Now imagine that's the only copy during an incident: the timeline from [Module 9](../../09-incident-response/12-timelines-and-postmortems.md) would be wrong, and "when did the attacker start?" couldn't be answered. Delete that index (**Stack Management → Index Management**).

**Real SIEMs use the event's own time**, from inside the log, never the time it arrived. And they normalize fields to a common schema, Elastic's is **ECS** (Elastic Common Schema), so `source.ip` means the same thing whether it came from SSH, CloudTrail, or a firewall.

## With Claude

Ask Claude Code:

```text
Here's one line from my auth.log and one CloudTrail event. Map each to
Elastic Common Schema (ECS) field names: timestamp, source IP, user,
action, and outcome. Tell me which ECS fields you're sure of and which
you're guessing.
```

Paste one line of each.

**Check the work:** look each field up in the [ECS reference](https://www.elastic.co/docs/reference/ecs/ecs-field-reference). `@timestamp`, `source.ip`, `user.name`, `event.action`, and `event.outcome` are real. AI sometimes invents plausible-sounding fields (`source.ip_address`, `user.username`). An invented field name in a detection rule matches nothing, silently, which is how real detections fail.

## Check yourself

1. Why does the time field matter so much?
   <details><summary>Answer</summary>

   Every search, dashboard, timeline, and detection rule is filtered by time. The wrong time field puts events in the wrong place, or hides them.
   </details>

2. What's the difference between structured and unstructured logs?
   <details><summary>Answer</summary>

   Structured logs (like CloudTrail JSON) arrive as named fields. Unstructured logs (like `auth.log`) are text, and the fields have to be extracted.
   </details>

3. What's ECS for?
   <details><summary>Answer</summary>

   A common set of field names, so the same idea (a source IP, a user) has the same name across every log source, and one rule or dashboard works on all of them.
   </details>

## Go deeper

- [Elastic Common Schema reference](https://www.elastic.co/docs/reference/ecs)
- [Elastic's AWS integration](https://www.elastic.co/docs/reference/integrations/aws): how real deployments pull CloudTrail straight from S3, already mapped to ECS.
