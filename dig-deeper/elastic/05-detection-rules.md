# Detection rules

**Pillars:** ☁️ Cloud · 🪪 Identity · 🤖 AI

## Why this matters

Searches answer questions you think to ask. **Detection rules** ask them for you, every few minutes, forever, and raise an **alert** when the answer looks like an attack. They're the core of a SIEM, and writing good ones, rules that catch real attacks without burying the team in false positives, is one of the most valued SOC skills.

You built two detections already: a CloudWatch alarm ([Module 9](../../09-incident-response/04-monitoring.md)) and `logslayer --detect` ([Module 9 project](../../09-incident-response/project.md)). Now you'll build them in a SIEM, with ATT&CK mapping, severity, and triage built in.

## Do it

1. **Freshen the data.** Rules look at recent events. Re-run the `jq` command from [lesson 2](02-getting-logs-in.md) to stamp the CloudTrail sample with the current time, and upload it again into `cloudtrail-lab`.

2. **Create a threshold rule** for the access-denied burst. Open **Security → Rules → Detection rules → Create new rule**, and choose **Threshold**:

   | Setting | Value | Why |
   |---|---|---|
   | Index patterns | `cloudtrail-lab` | |
   | Custom query | `errorCode : *` | Only denied or failed calls |
   | Group by | `userIdentity.arn` | Count per identity |
   | Threshold | `>= 5` | Same as your CloudWatch alarm |
   | Name | `AWS: burst of denied API calls by one identity` | Analysts read this first |
   | Description | What it detects, and what to check first | |
   | Severity | High | |
   | MITRE ATT&CK | Discovery (TA0007): Cloud Infrastructure Discovery (T1580), Account Discovery (T1087) | From [Module 9, lesson 9](../../09-incident-response/09-mitre-attack.md) |
   | Runs every | 5 minutes, with 1 hour of additional look-back | So the uploaded events fall inside its window |
   | Investigation guide | Your triage steps from [Module 9, lesson 8](../../09-incident-response/08-alert-triage.md) | The next analyst's instructions |

   Create and enable it.

3. **Create a custom query rule** for something that should **never** happen, so one event is enough:

   ```text
   eventName : CreateUser and userIdentity.arn : *ci-deploy*
   ```

   Name it `AWS: pipeline identity tried to create an IAM user`, severity Critical, mapped to Persistence: Create Account: Cloud Account (T1136.003). A pipeline has no reason to create users, ever. Rules like this, narrow and certain, are the best kind: almost no false positives.

4. **Wait for the alerts.** Within about five minutes, open **Security → Alerts**. Both should fire on `ci-deploy`. Open one: the alert shows the rule, the events that matched, the ATT&CK mapping, and your investigation guide. That's what the analyst on shift sees.

5. **Triage it in Elastic.** Use the alert's **Investigate in timeline** to see everything `ci-deploy` did around the alert. Mark the alert **Acknowledged**, add a note with your conclusion, then **Closed**. That's the workflow from [Module 9](../../09-incident-response/08-alert-triage.md), inside the tool.

6. **Export your rules** (**Detection rules → select → Export**) and commit them to `elastic/rules/`. Detection rules are code; they belong in version control, reviewed like any other change.

## Break it

**Tune a noisy rule.** Your threshold rule would also fire on your own Module 9 alarm test, and on Claude's view-only role whenever it explores ([Module 8](../../08-security-concepts/11-securing-ai.md)). Those are benign true positives. The lazy fix is raising the threshold to 20, which also lets a careful attacker through.

Instead, add an **exception** for exactly the known-benign case: `userIdentity.arn` contains `claude-readonly` **and** `sourceIPAddress` is your home IP. Note how narrow that is. An exception for "anything from `claude-readonly`" would mean that an attacker who stole the AI's role could probe all day without an alert. Write in `elastic/notes.md` why exceptions should be as specific as possible, and when they should be reviewed.

Then the opposite failure: write a rule that can never fire. Make a custom query rule for `errorcode : AccessDenied` (lowercase field name). Enable it. It never alerts, and nothing tells you it's broken: a **false negative** waiting to happen. Field names are case-sensitive. **Test every rule against data where it should fire.** Delete it.

## With Claude

Ask Claude Code to write a rule from a description, then review it like a detection engineer:

```text
Write an Elastic detection rule (as KQL, with suggested threshold and
settings) that detects a long-lived AWS access key (ID starting with AKIA)
being used from an IP address that identity has never used before. The
index has raw CloudTrail fields. Map it to MITRE ATT&CK.
```

**Check the work:**

- Can that be written as a simple KQL rule at all? "Never used before" needs history. Elastic has a **New terms** rule type for exactly this. Did Claude know, or did it write a KQL query that can't express "new"?
- Is the ATT&CK ID right? Check it on [attack.mitre.org](https://attack.mitre.org/) ([Module 9](../../09-incident-response/09-mitre-attack.md)).
- Is the field `userIdentity.accessKeyId`, exactly as in your data?

Build it with the New terms type if Claude didn't, test it against the sample, and add it to your exported rules.

## Check yourself

1. When do you use a threshold rule, and when a single-event custom query rule?
   <details><summary>Answer</summary>

   Threshold for patterns that only matter in volume (many denials). A single-event rule for things that should never happen at all (a pipeline creating users).
   </details>

2. How do you quiet a benign alert without hiding attacks?
   <details><summary>Answer</summary>

   A narrow exception for exactly the known-benign case (specific identity and source), never a broad one or a higher threshold for everyone.
   </details>

3. Why test every rule against data where it should fire?
   <details><summary>Answer</summary>

   A rule with a typo or wrong field name silently matches nothing, forever. You only find out when it misses a real attack.
   </details>

## Go deeper

- [Elastic detection rules](https://www.elastic.co/docs/solutions/security/detect-and-alert/create-detection-rule): every rule type.
- [Elastic's open detection rules repository](https://github.com/elastic/detection-rules): hundreds of real rules, with ATT&CK mapping, to read and learn from.
- [Sigma](https://sigmahq.io/): a vendor-neutral format for detection rules that converts to Elastic, Splunk, and others.
