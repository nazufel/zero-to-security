# What's an incident?

**Pillars:** ☁️ Cloud · 🪪 Identity

## Why this matters

In 2013, Target's security tools flagged the malware that would steal 40 million card numbers, days before the theft peaked. The alerts reached a security team. Nobody declared an incident, and the attack ran on. The problem wasn't detection. It was the decision.

Juniors often hesitate to "make a fuss." Experienced responders learn the opposite: **declaring early is cheap; declaring late is expensive.** An incident you declare and close in ten minutes costs ten minutes. One you sit on can cost the company.

## Do it

1. **Know the words.** An **event** is anything that happened (a login, an API call). An **alert** is an event a tool flagged. An **incident** is something that harms, or could harm, the confidentiality, integrity, or availability of systems or data ([Module 8](../08-security-concepts/01-foundations.md)), and needs a coordinated response.

2. **Use a severity scale.** Teams use one so nobody has to argue about how bad something is in the moment. This course uses PagerDuty's style:

   | Severity | Means | Example | Response |
   |---|---|---|---|
   | **SEV-1** | Critical: data stolen or at risk now, or the service is down for everyone | Customer data is being copied out | Everyone, now, day or night |
   | **SEV-2** | Major: serious impact or risk, contained or partial | A leaked key with admin access, not yet used | Respond now |
   | **SEV-3** | Minor: limited impact, no data at risk | One user's account locked by password guessing | Business hours |
   | **SEV-4** | Low: worth tracking, no real impact | A scanner probing closed ports | A ticket |

3. **Declare, in writing.** Create `incidents/README.md` in your portfolio with the template you'll use:

   ```markdown
   # Incident declaration

   **Declared:** (UTC time) by (name)
   **Severity:** SEV-?
   **What we know:** (facts only, 2–3 lines)
   **What we don't know yet:**
   **Impact (so far):**
   **Incident commander:**
   **Channel / bridge:**
   ```

   "Facts only" matters: early guesses spread fast and are usually wrong ([Module 0](../00-start-here/04-tickets-and-documentation.md): don't let anyone invent details).

4. **Practice deciding.** For each, write: incident or not, a severity, and one sentence of why. Add them to `incidents/README.md` under "Practice":

   1. CloudWatch shows 12 `AccessDenied` errors in 4 minutes from an IAM user called `ci-deploy`, from an IP you don't recognize.
   2. `logslayer` reports 5,000 failed SSH passwords from one IP. No successful logins.
   3. A developer says they pasted the production database password into a public chatbot an hour ago.
   4. The notes API returned errors for 2 minutes during a deploy, then recovered.
   5. A user reports a suspicious email but says they didn't click anything.

   <details><summary>One set of answers</summary>

   1. **Incident, SEV-2** (SEV-1 if any calls succeeded on data). A pipeline user shouldn't be probing from a new IP; it looks like a stolen key. Declare.
   2. **Not an incident yet (SEV-4).** Background noise on the internet. It becomes one the moment a login **succeeds**.
   3. **Incident, SEV-2.** A secret was disclosed outside the company. Rotate it now; check for use.
   4. **Probably not a security incident.** An operational blip; a ticket, and a look at why the deploy caused errors.
   5. **Not an incident, but worth an alert ticket.** Thank the reporter, block the sender, check whether anyone else got it or clicked (lesson 10). It becomes one if someone entered credentials.
   </details>

## Break it

Argue yourself out of declaring scenario 1, the way people really do: "It's probably the pipeline running from a new runner." "AccessDenied means it was blocked, so no harm done." "I don't want to wake anyone up."

Now write the cost of each excuse being wrong. If it **is** a stolen key, every hour of waiting is an hour the attacker keeps trying, and "denied" only tells you what **didn't** work; it says nothing about what did. The asymmetry is the whole lesson: declaring a false alarm costs a little time and some mild embarrassment; not declaring a real one costs the company. **When unsure, declare, then downgrade.**

## With Claude

Ask Claude Code:

```text
Give me five realistic security scenarios a junior SOC analyst might see,
from clearly-not-an-incident to clearly-SEV-1, and don't tell me the answers.
```

Classify each yourself, then ask Claude for its answers. **Check the work:** where you disagree, argue it out using the severity table. Watch for Claude underplaying something because "it was denied" or "no evidence of exfiltration yet." Absence of evidence early in an incident usually means you haven't looked yet. The final call on declaring is a **human** decision; you'll come back to that in lesson 13.

```bash
git add incidents/README.md
git commit -m "Incident declaration template and practice"
git push
```

## Check yourself

1. What's the difference between an alert and an incident?
   <details><summary>Answer</summary>

   An alert is something a tool flagged. An incident is real or likely harm to systems or data that needs a coordinated response. Many alerts are not incidents.
   </details>

2. You're 60% sure something is an incident. Declare or wait?
   <details><summary>Answer</summary>

   Declare. You can downgrade or close it if you're wrong. Waiting on a real one is far more costly.
   </details>

3. An attacker's calls were all denied. Is it still an incident?
   <details><summary>Answer</summary>

   Yes, if someone unauthorized has working credentials. Denials show what didn't work, not what did, and the credential itself must be contained.
   </details>

## Go deeper

- [PagerDuty: severity levels](https://response.pagerduty.com/before/severity_levels/): a real team's definitions, free to reuse.
