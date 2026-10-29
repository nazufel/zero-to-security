# MITRE ATT&CK

**Pillars:** ☁️ Cloud · 🪪 Identity

## Why this matters

When one analyst says "they did some recon, then grabbed the data," and another says "they enumerated, then exfiltrated," are they describing the same thing? **MITRE ATT&CK** is a free, public catalog of the tactics and techniques real attackers use, with an ID for each, so security teams everywhere can describe an attack the same way. It's on most SOC job postings.

It's also a thinking tool. An attack is a sequence of **tactics** (the attacker's goals, like "discovery" or "exfiltration"), each achieved with a **technique** (how). Once you recognize which step you're looking at, ATT&CK tells you what usually comes **next**, and where to look.

## Do it

1. **Explore.** Open the [ATT&CK Cloud matrix](https://attack.mitre.org/matrices/enterprise/cloud/). The columns are tactics, in roughly the order an attack unfolds: Initial Access, Execution, Persistence, Privilege Escalation, Defense Evasion, Credential Access, Discovery, Lateral Movement, Collection, Exfiltration, Impact. Each cell is a technique.

2. **Map a real attack.** Take the `ci-deploy` story from the [Module 6 sample](../06-cloud-aws/samples/cloudtrail-events.json). Create `incidents/attack-mapping.md`, and map each event to a tactic and technique:

   | Time | Event | Tactic | Technique |
   |---|---|---|---|
   | 02:10:05 | `GetCallerIdentity` with a key from an unknown IP | Initial Access | Valid Accounts: Cloud Accounts (T1078.004) |
   | 02:10:09 | `ListBuckets` (succeeded) | Discovery | Cloud Storage Object Discovery (T1619) |
   | 02:10:15 | `ListUsers` (denied) | Discovery | Account Discovery: Cloud Account (T1087.004) |
   | 02:10:19 | `GetSecretValue` (denied) | Credential Access | Credentials from Password Stores: Cloud Secrets Management Stores (T1555.006) |
   | 02:10:23 | `DescribeInstances` (denied) | Discovery | Cloud Infrastructure Discovery (T1580) |
   | 02:10:31 | `CreateUser` (denied) | Persistence | Create Account: Cloud Account (T1136.003) |
   | 02:11:02 | `GetParameter` (succeeded) | | |

   Fill in the blanks and the missing rows. Look each technique up on the ATT&CK site to check the ID. (They do get renumbered and renamed over time.)

3. **Ask "what's next?"** The attacker reached Discovery and tried Persistence. For each, read the technique's **Detection** section on the ATT&CK site. Which of your alarms (lesson 4) would catch it? Which wouldn't? Write one new detection idea per gap. For example, `CreateAccessKey` on any user would catch a common persistence move that your access-denied alarm only catches if it **fails**.

4. **Map your own controls.** For each technique in your table, write which control from this course blocks or detects it: the view-only roles, the access-denied alarm, CloudTrail data events, no long-lived keys, and so on. Where a technique has neither, that's a gap worth naming in the project's postmortem.

5. Commit `attack-mapping.md`.

## Break it

Map an attack with the wrong vocabulary, and see the cost. Suppose an analyst writes in the incident channel: "Attacker did privilege escalation via `ListBuckets`."

What would the team do with that? Privilege escalation means gaining **more** access: they'd start hunting for new roles, changed policies, and admin activity. But `ListBuckets` is **Discovery**: looking around with the access they already have. The right next step is to check what the key could **reach**, not to hunt for escalation that never happened. A wrong label sends people the wrong way, which is exactly the problem a shared vocabulary exists to fix. Write the correct label, and the correct next step, in your file.

## With Claude

Ask Claude Code:

```text
Map each event in ~/my-security-portfolio/cloud/cloudtrail-events.json to a
MITRE ATT&CK tactic and technique ID. Then tell me which technique the
attacker is most likely to try next, and what in CloudTrail would show it.
```

**Check the work:** check **every** technique ID on [attack.mitre.org](https://attack.mitre.org/). AI often gives an ID that's real but for the wrong technique, an old ID that was renumbered, or a sub-technique that doesn't exist. Compare with your own table. If Claude and the ATT&CK site disagree, the site wins. Log each wrong ID in your [AI check log](../01-ai-foundations/01-what-ai-is.md); this is a domain where a confident wrong answer goes straight into reports.

## Check yourself

1. What's the difference between a tactic and a technique?
   <details><summary>Answer</summary>

   A tactic is the attacker's goal at that step (like Discovery). A technique is how they achieve it (like Account Discovery: Cloud Account).
   </details>

2. An attacker with a stolen key calls `ListUsers` and `DescribeInstances`. Which tactic?
   <details><summary>Answer</summary>

   Discovery: learning what's in the account with the access they have.
   </details>

3. Why does a shared vocabulary matter during an incident?
   <details><summary>Answer</summary>

   Everyone understands exactly which step of the attack is being described, and what to check next, without misreading each other.
   </details>

## Go deeper

- [MITRE ATT&CK: Cloud matrix](https://attack.mitre.org/matrices/enterprise/cloud/)
- [ATT&CK Navigator](https://mitre-attack.github.io/attack-navigator/): color in the techniques you can detect, and see your gaps.
