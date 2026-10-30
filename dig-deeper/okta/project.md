# Project: a help desk runbook

**Pillars:** 🪪 Identity · ☁️ Cloud

## Why this matters

A **runbook** is the step-by-step guide a help desk follows for common tickets, so that every agent does it the same, safe way, even at 6 a.m. on a Saturday with a caller in a hurry. Writing one shows a hiring manager you understand the job and its risks, not just the buttons.

## What to build

`~/my-security-portfolio/okta/runbook.md`, with one section per ticket type. Each section has: how to verify the caller, the exact steps in Okta, what to check in the System Log, what to write in the ticket, and when to escalate instead.

## Steps

1. Write runbook sections for:
   - **Locked out**
   - **Forgot password**
   - **New phone, needs MFA reset**
   - **New starter** (joiner)
   - **Changing teams** (mover)
   - **Leaving today**, including apps outside Okta and active AWS sessions (leaver)
   - **"I didn't request this MFA push"**, which is a security incident, not a password ticket
2. **Test every section** in your Okta org with Jordan and Sam: follow your own steps exactly, as written. Fix any step that was wrong, missing, or in the wrong order.
3. Add **evidence**: for each tested section, the System Log events it produced (with emails and IPs redacted).
4. Include your AWS SSO setup from [lesson 6](06-sso-into-aws.md) in the leaver section: how removing the group ends AWS access, and what to do about sessions that are still active.
5. Commit, and add the runbook to your portfolio's "Start here" table if you're applying for help desk roles.

## With Claude

Have Claude play five different callers, one per section, some honest and some attackers, without telling you which. Follow your runbook for each. Afterward, ask Claude which were attackers. Did your runbook stop every attacker without blocking the honest callers? Fix the section that came closest to failing.

## Done when

- [ ] All seven sections exist, each tested in your org
- [ ] Every reset section starts with verification and says when to escalate
- [ ] The "I didn't request this MFA push" section treats it as a possible attack
- [ ] The leaver section covers apps outside Okta and active AWS sessions
- [ ] You'd be comfortable handing it to a new help desk hire on their first day
