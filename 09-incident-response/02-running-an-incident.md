# Running an incident

**Pillars:** 🪪 Identity · ☁️ Cloud

## Why this matters

When an incident starts, the natural instinct is for everyone to jump in and start typing commands. Within minutes, three people are changing the same system, nobody knows who did what, nobody has told the boss anything, and the evidence is getting trampled. Incidents are lost through chaos far more often than through lack of skill.

The fix is structure: a few **roles**, a rhythm of **updates**, and a written **timeline**. This course uses [PagerDuty's Incident Response guide](https://response.pagerduty.com/), which is free and used by real teams.

## The roles

| Role | Does | Doesn't |
|---|---|---|
| **Incident commander (IC)** | Runs the incident: decides, assigns tasks, keeps everyone focused | Fix things themselves. The IC's hands stay off the keyboard. |
| **Scribe** | Writes the timeline: every decision, action, and finding, with the time | Investigate |
| **Subject matter experts (SMEs)** | Investigate and fix the parts they know (cloud, identity, the app) | Act without telling the IC |
| **Communications liaison** | Sends regular status updates to people outside the incident | Speculate |

In a small team, one person may wear two hats. Never let the IC also be the main investigator: someone has to see the whole picture.

## Do it

You'll run a **tabletop exercise**: an incident played out by talking it through, with no real systems at risk. It's how teams practice. Use the Module 6 sample, the [`ci-deploy` CloudTrail export](../06-cloud-aws/samples/cloudtrail-events.json).

1. **Assign roles.** If you can, do this with a friend or two. Otherwise, you're the IC and you'll write each role's lines yourself.

2. **Declare.** Fill in the declaration template from [lesson 1](01-whats-an-incident.md) in `incidents/2026-03-14-ci-deploy-tabletop.md`. Severity? Facts only.

3. **Run it in rounds of 15 minutes** (pretend time). Each round, the IC asks three questions and the SMEs answer from the data:

   - **Round 1, scope:** What identity? What did it try? What succeeded? (Use `jq` and your `ct_summary.py` from [Module 6](../06-cloud-aws/11-cli-and-boto3.md).)
   - **Round 2, contain:** What's the one action that stops the bleeding? Who does it, and who approves it?
   - **Round 3, investigate:** What did the successful calls touch? What else could the key reach? Is the attacker still active?
   - **Round 4, recover and close:** What needs rotating or rebuilding? When is it over?

   The scribe logs every answer with a time.

4. **Send status updates.** After each round, the comms liaison writes a three-line update for "leadership":

   ```markdown
   **[SEV-2] ci-deploy key misuse: update 2 (02:40 UTC)**
   **Status:** Contained. The key was deactivated at 02:35.
   **Impact:** Bucket names and parameter names were listed. No data reads confirmed yet; investigating.
   **Next update:** 03:10 UTC, or sooner if anything changes.
   ```

   Status, impact, next update. No jargon, no guesses. A promised next-update time, kept, calms more people than any detail.

5. **Close it.** The IC declares the incident resolved and says when the postmortem will happen (lesson 12). Commit the file.

## Break it

Run round 1 again, badly, on purpose. This time, the IC also investigates, nobody scribes, and two SMEs both "fix" things: one deletes the `ci-deploy` user, the other is still reading its activity in CloudTrail.

Now answer, from your notes: at what time was the key disabled? Who decided? What was the user's policy before it was deleted? You can't say, and the last one is gone for good, because deleting the user deleted its inline policy, which was evidence of what the attacker **could** do.

Write two sentences in the tabletop file about what the structure in steps 1 to 4 prevents. The roles aren't bureaucracy. They're how you keep track of what you've done when your heart rate is up.

## With Claude

Ask Claude Code to play the incident with you:

```text
Run a tabletop incident exercise with me. You're the narrator: describe a
realistic AWS security incident one step at a time. I'm the incident
commander. Wait for my decisions before revealing what happens next. Use
PagerDuty's incident roles. After 6 turns, critique how I ran it.
```

**Check the work:** at the end, compare Claude's critique with PagerDuty's guide. Did it praise you for doing something the guide says the IC shouldn't (like investigating yourself)? Did it make up AWS behavior to move the story along (an API that doesn't exist, a log that wouldn't contain that field)? If so, catch it, it's practice for the real thing, where a made-up detail in an incident costs hours.

## Check yourself

1. Why shouldn't the incident commander investigate?
   <details><summary>Answer</summary>

   Someone has to keep the whole picture, make decisions, and coordinate. An IC with their head in a log file loses track of the team.
   </details>

2. What goes in a status update?
   <details><summary>Answer</summary>

   Current status, impact so far, and when the next update will come. Facts only, no jargon, no speculation.
   </details>

3. Why is the scribe's timeline so important?
   <details><summary>Answer</summary>

   It's the record of what was done, when, and by whom. You need it during the incident to avoid repeating or undoing work, and afterward for the postmortem.
   </details>

## Go deeper

- [PagerDuty Incident Response documentation](https://response.pagerduty.com/): the full guide, including "being an incident commander." Read the IC section now.
