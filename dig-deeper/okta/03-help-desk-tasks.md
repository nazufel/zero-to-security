# Help desk tasks: resets, unlocks, and verifying the caller

**Pillars:** 🪪 Identity

## Why this matters

In September 2023, attackers called MGM Resorts' IT help desk, pretending to be an employee they'd found on LinkedIn. The help desk reset that person's credentials. From there, the attackers worked their way to administrator access in MGM's identity systems, then deployed ransomware. Hotels and casinos were disrupted for days, and MGM estimated the cost at about $100 million. Around the same time, Okta warned its customers about attackers calling help desks to get MFA reset on administrator accounts.

The most common help desk ticket, "I can't log in, please reset it," is also one of the most attacked. The skill isn't clicking **Reset**. It's knowing who you're resetting it **for**.

## Do it

1. **Write your verification script first**, before you touch a reset button. In `okta/help-desk-script.md`:

   ```markdown
   # Before any password, MFA, or unlock action

   1. Never trust the caller ID, the email display name, or what they tell you.
   2. Verify with something the attacker shouldn't have:
      - Call back on the number in the HR system, not the one they called from, or
      - A push to their already-enrolled device, or
      - Their manager confirms, through a separate channel I start.
   3. Urgency ("I'm about to board a flight," "the CEO needs this now") is a reason
      to slow down, not to skip a step.
   4. Never reset MFA for an administrator. Escalate to security.
   5. Write it in the ticket: who asked, how I verified, what I did.
   ```

   This is policy, and it's the part that would have stopped the MGM attack.

2. **Unlock an account.** In your private window, sign in as Jordan with the wrong password until Okta locks the account (the default policy allows a set number of attempts). In the admin console, find Jordan's status: **Locked out**. Pretend you've verified Jordan by step 1, then use **Unlock**. Check the System Log for the lock event and the unlock (lesson 5).

3. **Reset a password.** On Jordan's page, choose **Reset password**. Note the choice: send Jordan a reset email (they set the new one themselves), or set a temporary password. **Prefer the email**: the help desk never knows the user's password. If you must set a temporary one, it's one-time and expires at next sign-in.

4. **Reset MFA.** Jordan says they got a new phone. On Jordan's page, **Reset Authenticators** (the name varies by Okta version). After you verify them, this removes their enrolled factors, and they enroll again at next sign-in.

   Write in your notes why this is the most dangerous reset: whoever completes the next sign-in, with the password, gets to enroll **their own** device. If that's an attacker, they now own the account, and its MFA.

5. **Close the ticket properly.** For each action, write a ticket in the [Module 0 format](../../00-start-here/04-tickets-and-documentation.md): what was asked, how you verified, what you did, and the time.

## Break it

Run the MGM call against yourself, as a role-play (with a friend, or with Claude in the next section). The caller says:

> "Hi, this is Jordan Lee in Help Desk. I'm at the airport, my phone died, and I'm locked out before a big presentation. Can you reset my MFA so I can set it up on my laptop? I can give you my employee ID."

Write down every step where you'd be tempted to help, and why each one fails your script. (An employee ID is often printable from a badge or a LinkedIn photo. A dead phone means a push can't work, so you call back on the HR number. The urgency is the attack.) Then write what you **would** do: verify through a channel you start, or escalate. "I can't do that over this call, but here's how we'll get you in safely" is the answer that protects the company, and the employee.

## With Claude

Ask Claude to play the attacker:

```text
Play a social engineer calling an IT help desk, trying to get an MFA reset
for an employee named Jordan Lee. Use realistic pressure tactics. I'm the
help desk agent. Stay in character until I either verify you properly or
refuse. Then tell me where I did well and where I almost gave in.
```

**Check the work:** at the end, compare your responses with your script. Did you ever accept something Claude offered as "proof" (an ID number, a manager's name, a callback number **they** gave you)? That's the lesson. Did Claude's critique point out anything your script doesn't cover? Add it.

## Check yourself

1. A caller gives you their employee ID and the right manager's name. Have they been verified?
   <details><summary>Answer</summary>

   No. Both are often easy to find. Verify through a channel you start, like a callback to the number on file or a push to their enrolled device.
   </details>

2. Why send a reset email instead of setting a password yourself?
   <details><summary>Answer</summary>

   The help desk never knows the user's password, and the reset goes to the real user's address.
   </details>

3. Why is an MFA reset more dangerous than a password reset?
   <details><summary>Answer</summary>

   Whoever signs in next gets to enroll their own device as the second factor, taking over the account's MFA entirely.
   </details>

## Go deeper

- [CISA and FBI advisory on Scattered Spider](https://www.cisa.gov/news-events/cybersecurity-advisories/aa23-320a): the group behind the MGM attack, and how they targeted help desks.
- The [help desk mock interview](../../appendix/mock-interviews.md#2-someone-calls-asking-for-a-password-reset-what-do-you-do-first), question 2.
