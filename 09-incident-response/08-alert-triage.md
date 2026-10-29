# Alert triage

**Pillars:** ☁️ Cloud · 🪪 Identity · 🤖 AI

## Why this matters

A SOC analyst's day is a queue of alerts. Most aren't attacks. The job is to decide, quickly and correctly, which ones are, and to write down why. Close a real attack as noise and the breach goes on. Escalate everything and the team drowns, stops trusting your judgment, and starts ignoring alerts, which is how real attacks get missed too.

This is the core skill of the [SOC analyst interview](../appendix/mock-interviews.md#interview-2-soc-analyst). Every question there is some version of "how do you tell?"

## The four outcomes

| | It **was** malicious | It **wasn't** malicious |
|---|---|---|
| **Alert fired** | **True positive**: caught it | **False positive**: noise |
| **No alert** | **False negative**: missed it (the dangerous one) | **True negative**: correctly quiet |

And one more you'll see constantly: a **benign true positive**. The alert is correct (the behavior really happened) but it's authorized: a penetration test, an admin doing their job, your own lesson 4 alarm test.

## The triage method

For every alert, in this order:

1. **What exactly fired?** Read the alert and the raw events behind it. Not a summary.
2. **Who?** Which identity, and is it a person, a service, or an AI agent? What does it normally do?
3. **Is this normal for them?** Same IP, same time of day, same actions as usual?
4. **Is there an explanation?** A change ticket, a deploy, a test, someone on vacation using a hotel's Wi-Fi?
5. **What succeeded?** Denials show intent; successes show impact.
6. **Decide and document.** True positive (escalate or declare), false positive (tune the alert), or benign (note why). If you can't decide, **escalate**.

## Do it

Triage each alert, using only the evidence given. Write your answer for each in `incidents/triage.md`: the outcome, your reasoning by the six steps, and what you'd do next.

**Alert 1:** `notes-access-denied-burst` fired at 14:05. The denied events are all from `assumed-role/claude-readonly/claude-code`, from your home IP, on `iam:CreateUser`, `s3:CreateBucket`, and `dynamodb:Scan`. You ran lesson 4's alarm test at 14:00.

**Alert 2:** `notes-api-errors` fired at 09:12. The notes function logged `AccessDeniedException` on `dynamodb:PutItem`. The pipeline deployed a change to `lambda.tf` at 09:10.

**Alert 3:** `logslayer` reports, from a server's `auth.log`: 412 failed SSH passwords for `root`, `admin`, and `oracle` from `203.0.113.88` overnight. No successful logins from that IP.

**Alert 4:** `notes-access-denied-burst` fired at 03:17. The denied events are from `user/ci-deploy`, an IAM user, from `203.0.113.99`, user agent `python-requests/2.32`. The calls are `iam:ListUsers`, `secretsmanager:ListSecrets`, `ec2:DescribeInstances`, `dynamodb:ListTables`, `iam:CreateUser`. The pipeline normally runs from GitHub's IP ranges, using the `gha-notes-deploy` role, and didn't run last night.

**Alert 5:** `logslayer` reports 3 failed SSH passwords for `maria`, then one `Accepted password for maria`, all from `10.0.2.2`, at 08:45 on a Monday.

<details><summary>One set of answers</summary>

1. **Benign true positive.** Real denials, by your own test, at the time you ran it. Note it and close. (Consider: should your tests use a tag or session name the alert can recognize?)
2. **True positive, but operational, not security.** A deploy removed a permission. Roll back or fix; ticket to the deploying team. Not a security incident.
3. **True positive for "scanning," not an incident.** Background internet noise (SEV-4). The key fact is **no success**. Block the IP if you like; confirm password login is off.
4. **True positive. Escalate and declare (SEV-2 or higher).** A pipeline identity behaving nothing like the pipeline: wrong principal type (a user, not the role), unknown IP, a scripting user agent, discovery calls across five services, at 3 a.m., with no pipeline run. This is the Module 6 sample, and the project's scenario. Next: what **succeeded**?
5. **Probably a false positive for attack** (a user mistyping her password on a Monday morning, from the internal network), but confirm: is `10.0.2.2` where Maria normally logs in from? A quick check, then close with a note. If it weren't her usual address, this pattern (failures, then success) would be the most dangerous one on this list.
</details>

## Break it

Make a lazy rule, and watch it fail. Suppose a tired analyst writes this rule: "Close any `access-denied-burst` alert where all the calls were denied: nothing got through, so no harm."

Apply it to alert 4. It gets closed. Now look at what the alert **didn't** show: the same key's **successful** calls, which never appear in a denied-events alert at all. In the Module 6 sample, `ListBuckets` and `GetParameter` succeeded. In the project, a `Scan` of every note will succeed. The rule closed an active data theft because the alert only showed the attempts that failed.

Write in `triage.md` why "all denied" is never enough to close an alert about an identity, and what query (from [lesson 7](07-querying-logs.md)) you'd run first instead.

## With Claude

Give Claude Code alert 4's evidence (copy the alert text), and ask:

```text
Triage this alert as a SOC analyst. Is it a true positive, false positive,
or benign? What would you check next, in order? Be specific about queries.
```

**Check the work:** does Claude reach "escalate"? Does it ask what **succeeded**? Its next steps should include containment (deactivating the key) early, not only investigation. If it suggests "contact the user to confirm," ask: which user? `ci-deploy` is a pipeline, not a person. An AI can be a fast second opinion in triage. The decision to close or escalate stays with you (lesson 13).

## Check yourself

1. What's the difference between a false positive and a benign true positive?
   <details><summary>Answer</summary>

   A false positive means the alert was wrong: the behavior wasn't what it claimed. A benign true positive means the behavior really happened, but was authorized.
   </details>

2. Which outcome is the most dangerous, and why?
   <details><summary>Answer</summary>

   A false negative: an attack that never alerted. Nobody is looking at it at all.
   </details>

3. You can't decide whether an alert is malicious. What do you do?
   <details><summary>Answer</summary>

   Escalate, with your notes. Closing a real attack is far worse than escalating a false alarm.
   </details>

## Go deeper

- The [SOC analyst mock interview](../appendix/mock-interviews.md#interview-2-soc-analyst): answer questions 1 and 2 out loud now.
