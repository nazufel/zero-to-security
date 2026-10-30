# Searching: KQL and ES|QL

**Pillars:** ☁️ Cloud · 🪪 Identity

## Why this matters

Searching is most of a SOC analyst's day. Every alert starts a set of questions ("what else did this identity do? has this IP been here before?"), and each question is a search. Elastic has two search languages worth knowing: **KQL**, for quick filters, and **ES|QL**, a pipe-based language for counting, grouping, and pulling fields out of text. If you can read a `grep | sort | uniq -c` pipeline from Module 2, ES|QL will feel familiar.

## Do it

1. **KQL: quick filters.** In **Discover**, with the `cloudtrail-lab` data view, type in the search bar:

   ```text
   errorCode : *
   ```

   Every event with an error. Then narrow it:

   ```text
   errorCode : AccessDenied and userIdentity.arn : *ci-deploy*
   ```

   Click a field name in the sidebar (try `sourceIPAddress`) to see its top values. That's `sort | uniq -c`, one click.

2. **ES|QL: the Module 9 questions.** Switch Discover to ES|QL (the language selector by the search bar). Each line takes the output of the one before it, like a pipe:

   ```esql
   FROM cloudtrail-lab
   | WHERE errorCode IS NOT NULL
   | STATS denied = COUNT(*) BY userIdentity.arn
   | SORT denied DESC
   ```

   Who was denied, and how often: the Athena query from [Module 9, lesson 7](../../09-incident-response/07-querying-logs.md), in Elastic. Now everything one identity did, by service:

   ```esql
   FROM cloudtrail-lab
   | WHERE userIdentity.arn LIKE "*ci-deploy*"
   | STATS calls = COUNT(*) BY eventSource, eventName
   | SORT calls DESC
   ```

3. **Pull fields out of text.** `auth.log` is mostly one `message` field. Extract the IP and count failed passwords per IP, the job `logslayer` does:

   ```esql
   FROM authlog-lab
   | WHERE message LIKE "*Failed password for*"
   | GROK message "from %{IP:src_ip} port %{NUMBER:src_port} ssh2"
   | STATS failures = COUNT(*) BY src_ip
   | SORT failures DESC
   ```

   `GROK` matches a pattern and pulls named pieces out into fields. Compare the counts with `logslayer samples/auth.log`. Set the time range to cover March 14, 2026, first.

4. **Find the success after the failures**, the most important question from [Module 2](../../02-linux/08-logs-and-pipes.md):

   ```esql
   FROM authlog-lab
   | WHERE message LIKE "*password for*"
   | GROK message "%{WORD:result} password for %{DATA:user} from %{IP:src_ip} port"
   | STATS failed = SUM(CASE(result == "Failed", 1, 0)),
           accepted = SUM(CASE(result == "Accepted", 1, 0)) BY src_ip
   | WHERE failed > 0 AND accepted > 0
   ```

   Two IPs: `203.0.113.7` (12 failures, then in) and `10.0.2.2` (Maria's typo). Exactly what your Module 3 challenge found.

5. **Save your searches** (the save button in Discover), and copy each into `elastic/queries.md` with one line on what question it answers.

## Break it

Look closely at step 3's results. Is there a phantom `10.0.0.1` in the counts?

Find the line from `198.51.100.23` with the strange username ([Module 3, lesson 7](../../03-python/07-never-trust-input.md)). The GROK pattern `from %{IP:src_ip} port` matches the **first** `from <ip> port` in the line, and the attacker typed a fake one into their username. Your SIEM query just made the same mistake as the naive parser. A SIEM doesn't make parsing safe; the pattern does.

Fix it by anchoring to the end of the line, which sshd writes:

```esql
| GROK message "from %{IP:src_ip} port %{NUMBER:src_port} ssh2$"
```

Run it again, and check that `10.0.0.1` is gone and `198.51.100.23` has 5. Attacker-controlled text is attacker-controlled text, in Python or in a SIEM.

## With Claude

Ask Claude Code:

```text
Write an ES|QL query over an index of raw CloudTrail events (fields like
userIdentity.arn, eventName, eventSource, errorCode, sourceIPAddress,
eventTime) that finds any identity that called GetCallerIdentity and then
got errors from 3 or more different services. Explain each line.
```

**Check the work:** run it in Discover. Does it use real ES|QL commands and functions? Check any you don't recognize in the [ES|QL reference](https://www.elastic.co/docs/reference/query-languages/esql). Does it return `ci-deploy`? Test it by also checking an identity that **shouldn't** match. ES|QL is newer than most query languages, so AI often mixes in syntax from SQL or Splunk's SPL that doesn't exist here. The error message tells you which line.

## Check yourself

1. When would you use KQL, and when ES|QL?
   <details><summary>Answer</summary>

   KQL for quick filtering in Discover. ES|QL when you need to count, group, sort, or extract fields from text.
   </details>

2. What does `GROK` do?
   <details><summary>Answer</summary>

   Matches a pattern against a text field and pulls named parts (like an IP address) out into their own fields.
   </details>

3. Why did the first GROK pattern count a fake IP?
   <details><summary>Answer</summary>

   It matched the first `from <ip> port` in the line, which was inside the attacker's chosen username. Anchoring to the end of the line, which sshd writes, fixes it.
   </details>

## Go deeper

- [ES|QL reference](https://www.elastic.co/docs/reference/query-languages/esql)
- [KQL reference](https://www.elastic.co/docs/reference/query-languages/kql)
