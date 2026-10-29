# The OWASP Top 10

**Pillars:** ☁️ Cloud · 🪪 Identity · 🤖 AI

## Why this matters

The OWASP Top 10 is the list of web application risks that security teams, auditors, and interviewers use as shared vocabulary. "How do you defend against A01?" is a real interview question. The good news: you've been defending against most of it since Module 3, one lesson at a time. This lesson connects the names to your own work, so you can answer with **evidence**, not definitions.

> **Last verified:** 2026-10-27 ([OWASP Top 10:2025](https://owasp.org/Top10/2025/)).

## Do it

1. **Fill in the map with your own evidence.** Create `security/owasp-top-10.md`. For each risk, write where you met it, the control you built, and a **link to the file** in your portfolio that proves it:

   | Risk | What it means | Where you met it | Your evidence |
   |---|---|---|---|
   | **A01** Broken Access Control | Users can act outside their permissions | Identity ([Module 7](../07-identity/)), zero trust (lesson 3) | `notes-app/infra/team.tf`, `test-team-access.sh`, the `AWS_IAM` delete route |
   | **A02** Security Misconfiguration | Insecure settings and defaults | OpenTofu, Block Public Access, IaC scanning (lesson 14) | |
   | **A03** Software Supply Chain Failures | Trusting components you can't verify | Chainguard, digests, cosign, the Trivy story ([Module 5](../05-containers/)) | |
   | **A04** Cryptographic Failures | Weak or missing encryption, bad password storage | Crypto basics ([Module 4](../04-networking/07-crypto-basics.md)), lesson 5 | |
   | **A05** Injection | Untrusted input treated as code or commands | Never trust input ([Module 3](../03-python/07-never-trust-input.md)), `textContent` in the front end | |
   | **A06** Insecure Design | Flaws in the design itself | Threat modeling (lesson 9) | |
   | **A07** Authentication Failures | Weak login, missing MFA, stolen sessions | MFA ([lesson 1](01-foundations.md)), `aws login`, no long-lived keys | |
   | **A08** Software or Data Integrity Failures | Trusting updates, code, or data without checking integrity | Signatures, pinned actions (lesson 13) | |
   | **A09** Security Logging and Alerting Failures | Not noticing an attack | CloudTrail ([Module 6](../06-cloud-aws/11-cli-and-boto3.md)), Module 9 | |
   | **A10** Mishandling of Exceptional Conditions | Errors that fail open or leak details | Errors ([Module 3](../03-python/06-errors.md)), the delete route failing closed | |

   Every row needs a real file. If you can't link one, that's a gap: write it down.

2. **Find your weakest row.** Which risk has the thinnest evidence? For most people at this point it's **A09**: you can read CloudTrail, but nothing **alerts** you. That's exactly what Module 9 fixes. Note it.

3. Commit `owasp-top-10.md`. It's one of the most useful pages in your portfolio for interviews: every answer comes with a link.

## Break it

Pick one risk and break your own app with it, then confirm the control holds. **A05, Injection**, through the front end. Deploy the app, open the site, and add this note:

```html
<img src=x onerror="alert('XSS')">
```

No alert pops up: the note shows as text, because the page uses `textContent`. Now find the line in `frontend/index.html` and change `item.textContent = note.text` to `item.innerHTML = note.text`. Apply, reload: an alert box. Every visitor to the page would run that attacker's code. Put `textContent` back, and apply. Then delete the note with a signed request (lesson 3).

One line of code is the difference between A05 and no A05. That's why a code review that knows the Top 10 is worth so much.

## With Claude

Ask Claude Code:

```text
Read security/owasp-top-10.md and the files it links to. For each row,
does the linked file really show the control I claim? Tell me which rows
are strong, which are weak, and which claims aren't supported by the code.
```

**Check the work:** this time Claude is checking **you**. For every claim it says is unsupported, look at the file. Is Claude right? You may have overstated something, which is a real risk in an interview, where the interviewer can open the file. For anything Claude says is strong, make sure it actually read the file rather than taking your word for it.

## Check yourself

1. What's A01, and how did you defend against it in the notes app?
   <details><summary>Answer</summary>

   Broken Access Control. Least-privilege roles per function, group-based team access tested with the simulator, and a delete route that requires a signed request from an allowed identity.
   </details>

2. Which Top 10 risk does a pinned, signature-verified base image defend against?
   <details><summary>Answer</summary>

   A03, Software Supply Chain Failures (and A08, integrity).
   </details>

3. What's the difference between A05 Injection and A06 Insecure Design?
   <details><summary>Answer</summary>

   Injection is a coding flaw: input handled as code. Insecure Design is a design flaw: the system is built to do something unsafe, even if the code is correct.
   </details>

## Go deeper

- [OWASP Top 10:2025](https://owasp.org/Top10/2025/): each risk's page lists real examples, prevention, and related CWEs.
- [OWASP Juice Shop](https://owasp.org/www-project-juice-shop/): break all ten yourself, in Docker, locally. (Dig Deeper.)
