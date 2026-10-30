# The System Log

**Pillars:** 🪪 Identity · 🤖 AI

## Why this matters

"I can't log in" has a dozen causes: a wrong password, a lockout, an expired password, a missing group, a policy blocking their location, an attacker who already changed the password. Guessing wastes everyone's time. The **System Log** records every sign-in attempt, every factor used, every reset, and every admin action, with the reason for each failure. It's CloudTrail for identity ([Module 6](../../06-cloud-aws/11-cli-and-boto3.md)), and the first place a help desk tech or SOC analyst looks.

## Do it

1. **Open Reports → System Log.** Set the range to the last 24 hours. Every row is an event: when, who (the **actor**), what (the **event type**), to whom (the **target**), and the outcome.

2. **Find Jordan's lockout** from [lesson 3](03-help-desk-tasks.md). Use the search bar with Okta's filter syntax:

   ```text
   target.alternateId eq "you+jordan@yourmail.com"
   ```

   Then just the failed sign-ins:

   ```text
   eventType eq "user.session.start" and outcome.result eq "FAILURE"
   ```

   Expand one. The **outcome reason** tells you why: `INVALID_CREDENTIALS`, `LOCKED_OUT`, `VERIFICATION_ERROR`. That's the answer to most "I can't log in" tickets, without asking the user a single question.

3. **Follow the help desk's actions.** Find your own admin actions on Jordan:

   ```text
   actor.alternateId eq "your-admin-email@example.com"
   ```

   The unlock, the password reset, the authenticator reset, each with a time. If an attacker ever talks a help desk agent into a reset, this is the evidence of who did it and when. (It's also why the help desk script in lesson 3 says to write it in the ticket: the log shows **what** happened, the ticket shows **why**.)

4. **Learn the events you'll use most.** Add to `okta/notes.md`:

   | Event type | Means |
   |---|---|
   | `user.session.start` | A sign-in attempt |
   | `user.authentication.auth_via_mfa` | An MFA check |
   | `user.account.lock` | An account locked out |
   | `user.account.reset_password` | A password reset (by admin or user) |
   | `user.mfa.factor.reset_all` | All of a user's authenticators reset |
   | `user.lifecycle.deactivate` | A user deactivated |
   | `group.user_membership.add` | Someone added to a group |

   Check each name by finding one in your own log. Event names occasionally change.

5. **Export for analysis.** Use **Download CSV** for the last 24 hours. Save it as `okta/system-log-sample.csv`, **but** check it first: it contains real email addresses and IP addresses. For your portfolio, replace them with placeholders ([Module 1](../../01-ai-foundations/04-what-never-goes-in.md)), or keep the file out of Git.

## Break it

Investigate an account takeover pattern, on yourself. In your private window, as Jordan:

1. Fail the password three times.
2. Sign in successfully.
3. Enroll a **new** authenticator.

Now look at it in the System Log the way an analyst would, and write the sequence in your notes. Failures, then a success, then a new factor enrolled, minutes apart: if that wasn't Jordan, that's an attacker who guessed or phished the password and is now adding their own MFA so they can come back. It's the [Module 2](../../02-linux/08-logs-and-pipes.md) pattern (failures then success), plus **persistence** from [Module 9's ATT&CK lesson](../../09-incident-response/09-mitre-attack.md). The new-factor event is the one to alert on. In real life, the next step would be to suspend the account and call Jordan on the number in HR.

## With Claude

Give Claude Code your **redacted** CSV export:

```text
Read okta/system-log-sample.csv (an Okta System Log export, with emails and
IPs replaced). Summarize each user's activity in time order, and flag any
sequence that looks like an account takeover. Show which rows support each
flag.
```

**Check the work:** check every flagged sequence against the rows it cites. Did it find your Break it sequence? Did it flag your own admin resets as suspicious? (They are worth a look, which is a good instinct, but your ticket notes explain them.) Did it state a conclusion ("Jordan's account was compromised") instead of what the evidence shows? That's the line from [Module 9, lesson 13](../../09-incident-response/13-ai-in-the-soc.md): AI reads and summarizes; the analyst decides.

## Check yourself

1. A user says they can't log in. Where do you look first, and for what?
   <details><summary>Answer</summary>

   The System Log, filtered to that user's `user.session.start` failures. The outcome reason usually says exactly why.
   </details>

2. What sequence of events suggests an account takeover?
   <details><summary>Answer</summary>

   Failed sign-ins, then a success, then a new authenticator enrolled or a password changed, close together, especially from an unfamiliar location.
   </details>

3. Why does the help desk still write tickets if the System Log records every action?
   <details><summary>Answer</summary>

   The log shows what was done. The ticket shows why, who asked, and how they were verified, which the log can't.
   </details>

## Go deeper

- [Okta System Log query syntax](https://developer.okta.com/docs/reference/system-log-query/)
- [Okta event types](https://developer.okta.com/docs/reference/api/event-types/): the full list.
