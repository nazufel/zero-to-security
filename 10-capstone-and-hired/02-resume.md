# A resume with zero experience

## Why this matters

"No experience" is the wall every career changer hits, and it's mostly a wording problem. You don't have job titles in security. You do have projects with real results, built the way the job is done, with evidence anyone can check. A resume that says "passionate about cybersecurity, familiar with AWS" gets skipped. One that says "cut a container image's known vulnerabilities from hundreds to zero" gets read.

## Do it

1. **Use one simple layout.** One page. A plain format with no columns, tables, or graphics, because many companies run resumes through software that can't read them. Sections, in this order:

   ```text
   Name · City (or "Remote") · email · GitHub link · LinkedIn (optional)

   Summary          2 lines: what you do and the role you want
   Projects         Your strongest work, as bullets with results
   Skills           Grouped, honest, matching what you can prove
   Experience       Your previous jobs, with transferable bullets
   Education        Including this course, if you like, linked
   ```

   **Projects go above experience.** For a career changer, they're the evidence.

2. **Turn projects into bullets.** Use this shape: **action verb + what you built + how + result or proof.**

   | Weak | Strong |
   |---|---|
   | Used Docker and Chainguard | Rebuilt a Python tool's container on a minimal base image, cutting known vulnerabilities from hundreds to zero (Grype), with signature verification and digest pinning |
   | Familiar with AWS IAM | Designed least-privilege IAM for a serverless app: per-function roles, group-based team access, and an AI agent role, verified with a policy-simulator test suite |
   | Knowledge of incident response | Ran a simulated credential-leak incident end to end: CloudWatch alarm detection in ~15 min, key containment, CloudTrail data-event forensics, and a blameless postmortem |
   | Python scripting | Built a log analysis CLI that detects brute force, credential misuse, and discovery bursts in SSH and CloudTrail logs, with tests and an attacker-controlled-input regression test |

   Write five or six for your strongest projects in `career/resume-bullets.md`. Use **your** numbers: your scan counts, your detection time, your test counts.

3. **Translate your past jobs.** Every job has security-relevant skills. A retail manager handled cash controls and incident escalation. A teacher wrote clear documentation for non-experts and handled confidential records. A nurse followed strict protocols under pressure and documented everything. For each previous job, write one bullet that shows a skill from [Module 0](../00-start-here/01-the-jobs.md)'s job research: troubleshooting, clear writing, calm under pressure, following procedure.

4. **List skills you can prove.** Group them, and only list what your portfolio shows:

   ```text
   Cloud: AWS (IAM, Lambda, API Gateway, DynamoDB, S3, CloudFront, VPC, CloudTrail, CloudWatch), OpenTofu
   Security: least privilege, threat modeling (STRIDE), incident response, phishing analysis, vulnerability triage
   Tools: Linux, Python, Bash, Git, Docker, GitHub Actions (OIDC), Grype, Checkov, Wireshark, nmap
   AI: Claude Code with managed settings, hooks, and least-privilege AI roles
   ```

5. **Tailor it for each application.** Take three real postings from your [Module 0 job research](../00-start-here/01-the-jobs.md) (or new ones). For each, reorder your bullets so the ones that match the posting come first, and use the posting's words where they're true ("SIEM" if they say SIEM and you can explain how CloudWatch alarms relate). Save the tailored versions.

## Break it

Find the claims you couldn't defend. Read your resume line by line and, for each, ask: "If an interviewer said 'tell me more about that,' could I talk for two minutes, with a specific example?"

Mark every line where the answer is no. Those lines are liabilities: one stumble on a resume claim makes an interviewer doubt everything else. Rewrite them down to what you actually did, or cut them. A shorter, true resume beats a longer, inflated one every time.

## With Claude

Paste one posting and your bullets into Claude Code:

```text
Here is a job posting and my resume bullets. Which of my bullets best match
the posting, and in what order should they go? Suggest stronger wording for
three of them, but don't add skills or results I haven't listed.
```

**Check the work:** compare each rewrite with the original. Did it inflate anything? "Built" becoming "architected," "simulated incident" becoming "led incident response," a "~15 minute" detection time becoming "reduced detection time by 80%"? Every one of those is a question you can't answer in an interview. Keep the clearer wording, and keep the facts exactly as they were.

## Check yourself

1. Why put projects above experience on a career-changer's resume?
   <details><summary>Answer</summary>

   They're the direct evidence for the job you want. Previous jobs show transferable skills, but projects show you can do this work.
   </details>

2. What's the shape of a strong project bullet?
   <details><summary>Answer</summary>

   Action verb, what you built, how, and a result or proof, ideally a number you measured.
   </details>

3. You can't talk for two minutes about a line on your resume. What do you do?
   <details><summary>Answer</summary>

   Rewrite it to what you actually did, or remove it.
   </details>

## Go deeper

- Your [Module 0 job research](../00-start-here/01-the-jobs.md): reread it now. Compare the skills you couldn't recognize then with your skills list today.
