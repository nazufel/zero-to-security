# Querying logs with Athena

**Pillars:** ☁️ Cloud · 🪪 Identity

## Why this matters

`filter-log-events` and `jq` are fine for a few hundred lines. A real company's CloudTrail can be millions of events a day, across months. Investigators need to ask questions like "every action this key took in the last 30 days, grouped by service," and get an answer in seconds.

**Athena** runs SQL queries directly on files in S3, including your CloudTrail bucket. No database to set up; you pay only for the data each query reads, which for a lab is fractions of a cent. SQL is also one of the most common skills on SOC job postings, so this lesson doubles as a start on it.

## Do it

1. **Give Athena a place to put results.** In the console, open **Athena**. If it asks for a query result location, create a bucket for it (for example, `notes-athena-results-<your account ID>`) and set `s3://that-bucket/` as the location in **Settings**. Block Public Access stays on.

2. **Create a table over your trail.** CloudTrail can write the table definition for you. Open **CloudTrail → Event history**, click **Create Athena table**, choose your trail's bucket (`notes-trail-...`), and create it. Note the table name it shows (something like `cloudtrail_logs_notes_trail_...`).

   > **Cost:** Athena charges about $5 per terabyte scanned. Your trail is a few megabytes, so a query costs well under a cent. At work, tables are **partitioned** by date so queries only read the days they need.

3. **Ask your first question:** who did what, most recently?

   ```sql
   SELECT eventtime, useridentity.arn, eventname, sourceipaddress, errorcode
   FROM cloudtrail_logs_notes_trail_xxxxxxxx
   ORDER BY eventtime DESC
   LIMIT 20;
   ```

   Paste your table name in place of `cloudtrail_logs_notes_trail_xxxxxxxx`.

4. **Ask an investigator's questions.** Save each query and its answer in `incidents/queries.md`:

   **Every identity that was denied, and how often:**

   ```sql
   SELECT useridentity.arn, count(*) AS denied
   FROM cloudtrail_logs_notes_trail_xxxxxxxx
   WHERE errorcode LIKE '%Denied%' OR errorcode LIKE '%Unauthorized%'
   GROUP BY useridentity.arn
   ORDER BY denied DESC;
   ```

   **Everything one identity did, by service:**

   ```sql
   SELECT eventsource, eventname, count(*) AS calls
   FROM cloudtrail_logs_notes_trail_xxxxxxxx
   WHERE useridentity.arn LIKE '%claude-readonly%'
   GROUP BY eventsource, eventname
   ORDER BY calls DESC;
   ```

   **Who read the notes table** (a data event, from lesson 3):

   ```sql
   SELECT eventtime, useridentity.arn, sourceipaddress
   FROM cloudtrail_logs_notes_trail_xxxxxxxx
   WHERE eventname = 'Scan'
   ORDER BY eventtime DESC;
   ```

   **Every IP that used a given access key** (useful for a leaked key):

   ```sql
   SELECT DISTINCT sourceipaddress, useragent
   FROM cloudtrail_logs_notes_trail_xxxxxxxx
   WHERE useridentity.accesskeyid = 'AKIA...';
   ```

5. Commit `queries.md`. You'll run these against the incident in the project.

## Break it

Write a query that's wrong in a quiet way. Find denied calls with:

```sql
SELECT count(*) FROM cloudtrail_logs_notes_trail_xxxxxxxx WHERE errorcode = 'AccessDenied';
```

Compare its count with the `LIKE '%Denied%'` query from step 4. Different. DynamoDB returns `AccessDeniedException`, EC2 returns `UnauthorizedOperation`, and others vary too. An exact match quietly misses them, and an analyst who trusts that count tells the incident commander "only 3 denials" when there were 10. It's `grep "failed password"` from [Module 2](../02-linux/08-logs-and-pipes.md) all over again: **never trust a number from a filter you haven't checked against the raw data.**

## With Claude

Ask Claude Code to write a query for you:

```text
I have a CloudTrail table in Athena (default CloudTrail schema). Write a
SQL query that finds any identity that called sts:GetCallerIdentity and then,
within 10 minutes, got denied on three or more different services.
```

**Check the work:** this is a hard query, and a classic place for AI to be confidently wrong. Run it. Does it use real column names from your table (`useridentity.arn`, `eventsource`, `eventtime`)? `eventtime` is a **string** in the default schema; did Claude convert it (`from_iso8601_timestamp`) before comparing times? Test it against known data: Claude's role from lesson 4's alarm test should show up if you include a `GetCallerIdentity` first. If it returns nothing, the query is wrong, not the account clean.

## Check yourself

1. Why use Athena instead of `filter-log-events` for an investigation?
   <details><summary>Answer</summary>

   It runs SQL across all the log files in S3, over any time range, with grouping and counting, in seconds, and at large scale.
   </details>

2. Your query for `errorcode = 'AccessDenied'` returns 3. Is that the number of denied calls?
   <details><summary>Answer</summary>

   Probably not. Services use different error codes (`AccessDeniedException`, `UnauthorizedOperation`). Use a broader match and check it against the raw logs.
   </details>

3. How do you keep Athena costs low at scale?
   <details><summary>Answer</summary>

   Partition tables by date and filter on the partition, so each query reads only the days it needs. You pay per byte scanned.
   </details>

## Go deeper

- [Querying CloudTrail logs with Athena](https://docs.aws.amazon.com/athena/latest/ug/cloudtrail-logs.html): including partition projection.
