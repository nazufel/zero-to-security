# MFA and passkeys

**Pillars:** 🪪 Identity

## Why this matters

In [Module 8](../../08-security-concepts/01-foundations.md) you ranked MFA types: SMS and codes can be phished, push can be fatigued, and passkeys can't be phished at all. In an IdP, that's not a personal choice; it's a **policy** you set for everyone. Setting it is one of the highest-value things an identity team does: it decides whether a stolen password is a disaster or a non-event.

## Do it

1. **See what's available.** Open **Security → Authenticators**. You'll see Password, Email, Okta Verify (an app with push and codes), Phone (SMS and voice), and **FIDO2 (WebAuthn)**, which is passkeys and security keys. Some may need enabling with **Add authenticator**.

   Fill in `okta/notes.md`:

   | Authenticator | Phishing-resistant? | Use it for |
   |---|---|---|
   | Password | No | Never alone |
   | Email | No | Recovery only, if at all |
   | Phone (SMS) | No | Avoid: SIM swapping |
   | Okta Verify (push) | No, unless number challenge is on | Everyday users, with number challenge |
   | FIDO2 (passkey or security key) | **Yes** | Admins, and everyone who can |

2. **Turn on passkeys.** Add the **FIDO2 (WebAuthn)** authenticator if it isn't already active, and set its enrollment to **Optional** for everyone.

3. **Require phishing-resistant MFA for admins.** Open **Security → Authentication Policies**, and find the policy for the **Okta Admin Console**. Add a rule (above the default) that applies to admins and requires **possession factor + phishing resistant**. Save it.

   > **Before you save, check you have a passkey enrolled** on your admin account (step 4 of [lesson 1](01-your-okta-org.md)). Otherwise you'll lock yourself out of your own admin console. That's the [firewall lesson](../../04-networking/08-firewalls.md), in identity form.

4. **Make Jordan enroll a passkey.** In your private window, sign in as Jordan, open **Settings** (the end-user dashboard), and add a **security key or biometric** authenticator. Your laptop's fingerprint reader, Windows Hello, or your phone can act as a passkey.

5. **Check what happened.** In the admin console, look at Jordan's **Authenticators**: the passkey is listed. In the System Log (lesson 5), find the enrollment event.

## Break it

Run the [Module 9 phishing email](../../09-incident-response/10-phishing-analysis.md) against each kind of MFA, on paper. Jordan clicks the link and lands on a perfect copy of the Okta sign-in page at `rnicrosoft-support.example`. For each factor, write what the attacker gets:

| Jordan uses | What happens on the fake page | Attacker gets in? |
|---|---|---|
| Password only | Jordan types it | Yes |
| Password + SMS code | Jordan types both; the attacker relays them to the real Okta within seconds | Yes |
| Password + Okta Verify push | The attacker signs in with the password; Jordan gets a push and, expecting one, taps Approve | Usually |
| Password + push with number challenge | Jordan has to type a number shown on the **real** sign-in screen, which they can't see | Much harder |
| Passkey | The browser looks for a passkey for `rnicrosoft-support.example`, finds none, and offers nothing to type | No |

Now look at the real thing: sign in as Jordan with the passkey, and read the browser's passkey prompt closely. It names the site the passkey belongs to. That check happens in the browser, by exact address, not in Jordan's judgment at 6 a.m. on a Saturday. That's why "phishing-resistant" isn't marketing: it removes the step where a person has to notice the fake.

## With Claude

Ask Claude Code:

```text
Write an Okta MFA rollout plan for a 200-person company currently using SMS
codes, moving to passkeys. Order it by risk: who moves first, and why. Include
what the help desk needs ready before each step.
```

**Check the work:** admins and IT should go first (highest risk, most technical). Does the plan handle people without a phone or laptop that supports passkeys (security keys)? Does it plan for lost passkeys, which is a help desk ticket that must follow your [lesson 3 script](03-help-desk-tasks.md)? Does it leave SMS on "temporarily" with no end date? Every step in a rollout needs a date when the old method turns off, or it never does.

## Check yourself

1. Which MFA type resists phishing, and why?
   <details><summary>Answer</summary>

   Passkeys and security keys (FIDO2/WebAuthn). They're tied to the real site's address, so a lookalike site can't use them.
   </details>

2. Why require phishing-resistant MFA for admins first?
   <details><summary>Answer</summary>

   Admin accounts can change everyone's access. They're the most valuable target, so they get the strongest protection.
   </details>

3. Before tightening the admin authentication policy, what do you check?
   <details><summary>Answer</summary>

   That your own admin account already has the required factor enrolled, so you don't lock yourself out.
   </details>

## Go deeper

- [FIDO Alliance: passkeys](https://fidoalliance.org/passkeys/): how they work, in plain language.
