# Foundations

**Pillars:** ☁️ Cloud · 🪪 Identity

## Why this matters

In 2022, an attacker bought an Uber contractor's stolen password, then sent the contractor push notification after push notification asking them to approve a login. After an hour of this, plus a message pretending to be Uber IT, the contractor tapped "approve." The attacker was in. The password was the first wall, MFA was the second, and a tired human was the third.

Security people have a small vocabulary for thinking about this. You've been using its ideas for seven modules. This lesson names them, so you can use them on purpose, and in interviews.

## The vocabulary

**The CIA triad:** what you're protecting.

| | Means | Broken when | In the notes app |
|---|---|---|---|
| **Confidentiality** | Only the right people can see it | Data leaks | Private buckets, least-privilege roles, HTTPS |
| **Integrity** | Nobody can change it without permission | Data is tampered with | IAM on delete, versioning, signed images |
| **Availability** | It works when needed | It's down or too slow | Throttling, `tofu apply` from scratch, backups |

**Defense in depth:** many layers, so one failure isn't a disaster. You've built it since Module 1 as the "AI in a box": a VM, containers, roles, deny rules, and logs.

**Authentication vs. authorization:** who you are, and what you're allowed to do ([Module 7](../07-identity/01-identity-101.md)).

**MFA (multi-factor authentication):** proving who you are with two different kinds of factor: something you **know** (a password), something you **have** (a phone, a security key), or something you **are** (a fingerprint).

## Do it

1. **Map your own controls.** Create `security/foundations.md` in your portfolio. For each letter of CIA, list every control in the notes app that protects it, with the file or setting:

   ```markdown
   | CIA | Control | Where |
   |---|---|---|
   | Confidentiality | Files bucket blocks public access | notes-app/infra/s3.tf |
   | ... | | |
   ```

   Aim for at least five per letter. Availability is usually the shortest list. Notice that.

2. **Layer it.** Pick one threat, "someone steals the notes," and list every layer between an attacker on the internet and the data, in order. If one layer fails, what's the next one?

3. **Rate your MFA.** Not all MFA is equal. Check what's on your accounts:

   ```bash
   aws iam list-mfa-devices --user-name admin
   ```

   | MFA type | Phishing-resistant? | Why |
   |---|---|---|
   | SMS code | No | Codes can be phished, and phone numbers can be stolen with a SIM swap |
   | Authenticator app code | No | A fake login page can ask for the code and use it in real time |
   | Push approval | No | "MFA fatigue": keep sending until someone taps yes (the Uber attack) |
   | Push with number matching | Better | The user must type a number shown on the real login screen |
   | Passkey / security key (FIDO2) | **Yes** | The key checks the website's real address, so a fake site gets nothing |

   Add your accounts (AWS root, AWS admin, GitHub, email) and their MFA type to `foundations.md`. If any use SMS, upgrade them this week. GitHub and AWS both support passkeys.

## Break it

Run the Uber attack against yourself, on paper. Write out the steps an attacker would take to get into your **AWS admin** account, starting from "I have Alice's password." For each step, which control stops them, and which letter of CIA they'd break if it didn't?

Then do the same starting from "I have Alice's laptop, unlocked." Which layers are left? (Hint: your `aws login` session, your VM, and your GitHub login live there. That's why sessions expire, and why you sign out.)

## With Claude

Ask Claude Code:

```text
Read the files in notes-app/. Map every security control you can find to the
CIA triad. Then tell me which letter is weakest, and why.
```

**Check the work:** compare with your own table. Did Claude find controls you missed? Did it list anything that isn't actually in the code, like "WAF protects the API" or "data is backed up," which you haven't built? An AI confidently describing controls that don't exist is exactly how a security review goes wrong. Check every line against a file.

```bash
git add security/foundations.md
git commit -m "Add security foundations notes"
git push
```

## Check yourself

1. Throttling the API protects which letter of CIA?
   <details><summary>Answer</summary>

   Availability. It stops a flood of requests from taking the app down (or running up a bill).
   </details>

2. Why isn't an authenticator app code phishing-resistant?
   <details><summary>Answer</summary>

   A fake login page can ask for the code and pass it to the real site within seconds. A passkey or security key checks the site's real address, so it won't work on a fake one.
   </details>

3. Give an example of defense in depth from this course.
   <details><summary>Answer</summary>

   Claude Code: it runs in a VM, has deny rules for `sudo` and `aws`, reaches AWS only through its own view-only role, and its actions are logged in CloudTrail under its own name. Any one layer can fail without disaster.
   </details>

## Go deeper

- [CISA: phishing-resistant MFA](https://www.cisa.gov/sites/default/files/publications/fact-sheet-implementing-phishing-resistant-mfa-508c.pdf): why passkeys and security keys are the goal.
