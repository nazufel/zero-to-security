# Timelines and postmortems

**Pillars:** ☁️ Cloud · 🪪 Identity · 🤖 AI

## Why this matters

An incident isn't over when the attacker is out. It's over when you understand how it happened and have changed something so it can't happen the same way again. The **postmortem** is that document. Teams that skip it get the same incident twice.

Good postmortems are **blameless**: they ask what in the system let a mistake happen, not who made it. People who fear blame hide mistakes, and hidden mistakes become incidents. They're also specific: an exact timeline, clear impact, and action items with an owner and a date.

## Do it

1. **Build a timeline from evidence.** You'll use the [Module 6 sample CloudTrail](../06-cloud-aws/samples/cloudtrail-events.json) as the incident, plus the tabletop decisions from [lesson 2](02-running-an-incident.md). Pull every event into one sorted list:

   ```bash
   jq -r '.Events[] | .CloudTrailEvent | fromjson
     | "\(.eventTime)  \(.userIdentity.arn | split("/") | last)  \(.sourceIPAddress)  \(.eventName)  \(.errorCode // "OK")"' \
     ~/my-security-portfolio/cloud/cloudtrail-events.json | sort
   ```

   Then merge in the human events from your tabletop: when the alarm fired, when someone declared, when the key was disabled. A real timeline mixes **what the systems recorded** with **what the people did**, all in UTC.

2. **Write the postmortem.** Create `incidents/postmortem-template.md` from this, then fill a copy for the `ci-deploy` tabletop as `incidents/2026-03-14-ci-deploy-postmortem.md`:

   ```markdown
   # Postmortem: <short title>

   **Date:** · **Severity:** · **Authors:** · **Status:** draft / final

   ## Summary
   Three sentences: what happened, the impact, and the main fix.

   ## Impact
   What data or systems were affected, for how long, and for whom. Say what
   you **know**, and separately, what you **can't rule out**.

   ## Timeline (UTC)
   | Time | Event | Source |
   |---|---|---|

   ## Root cause and contributing factors
   Why it happened. Ask "why?" until you reach something in the system,
   not a person.

   ## Detection
   How we found out, how long it took, and how we could find out sooner.

   ## What went well / what didn't

   ## Action items
   | Action | Type (prevent / detect / respond) | Owner | Due |
   |---|---|---|---|
   ```

3. **Ask "why?" five times** for the root cause. For the `ci-deploy` incident, for example:

   1. Why could an attacker call AWS? They had a valid access key for `ci-deploy`.
   2. Why did they have it? It leaked from where the pipeline stored it.
   3. Why was there a key to leak? The pipeline used an IAM **user** with a long-lived key.
   4. Why? It was set up before the team used OIDC, and never migrated.
   5. Why was it never migrated? Nothing tracked long-lived keys, so nobody knew it was still there.

   The fix for #5 (an alarm or report on any IAM user with an active key) prevents the **next** leaked key, not just this one. "The developer should have been more careful" never appears.

4. **Write action items that are real.** Each has a type, an owner, and a date:

   | Action | Type | Owner | Due |
   |---|---|---|---|
   | Delete the `ci-deploy` user; pipeline uses OIDC only | Prevent | Pipeline owner | Done |
   | Alarm on `CreateAccessKey` for any user | Detect | Security | +1 week |
   | Weekly credential report check for active access keys | Detect | Security | +2 weeks |
   | Add "rotate and audit long-lived keys" to the incident runbook | Respond | IC on-call | +2 weeks |

5. Commit both files.

## Break it

Rewrite the postmortem's root cause **with blame**: "The DevOps engineer stored the access key insecurely and failed to rotate it."

Then answer from the engineer's side: next time they make a mistake, do they report it right away, or quietly fix it and hope? And from the system's side: what changed? Nothing: the next engineer can still create a user with a key, and nothing will notice. A blame-based postmortem punishes one person and leaves the system exactly as dangerous as before. Write both versions side by side in your file, and note which one produces action items.

## With Claude

Ask Claude Code to draft a postmortem from your evidence:

```text
Using only incidents/2026-03-14-ci-deploy-tabletop.md and the CloudTrail
export at ~/my-security-portfolio/cloud/cloudtrail-events.json, draft a
blameless postmortem in the format of incidents/postmortem-template.md.
Mark anything you're inferring rather than reading from the evidence.
```

**Check the work**, line by line against the evidence:

- **Every timeline entry:** is it in the export or the tabletop file, at that exact time? AI drafts love to add plausible events that never happened ("02:15: attacker attempted lateral movement").
- **Impact:** does it claim data was or wasn't stolen? The sample has no data events, so it **can't** know. The honest answer is "can't rule out." This is the most important check: an impact statement that's wrong in either direction misleads everyone who reads it.
- **Blameless?** Any sentence that names a person as the cause gets rewritten.

A postmortem draft is one of the best uses of AI in incident response: the structure is tedious and AI is fast. The facts are yours to verify.

## Check yourself

1. What makes a postmortem blameless, and why does it matter?
   <details><summary>Answer</summary>

   It looks for what in the system allowed the mistake, not who made it. People who don't fear blame report mistakes early, and system fixes prevent repeats.
   </details>

2. What does every action item need?
   <details><summary>Answer</summary>

   A type (prevent, detect, or respond), an owner, and a due date. Without an owner and date, it won't happen.
   </details>

3. Your evidence can't show whether data was read. What does the impact section say?
   <details><summary>Answer</summary>

   Exactly that: what you know, and that data access can't be ruled out, with why (for example, no data events were logged). Never fill a gap with a guess.
   </details>

## Go deeper

- [PagerDuty: postmortems](https://postmortems.pagerduty.com/): a free guide, with templates and how to run the meeting.
- [Google SRE book: postmortem culture](https://sre.google/sre-book/postmortem-culture/): why blameless works.
