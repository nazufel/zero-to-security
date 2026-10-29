# The capstone

**Pillars:** ☁️ Cloud · 🪪 Identity · 🤖 AI

## Why this matters

A hiring manager looking at your portfolio gives it about a minute. In that minute, they decide whether to read further, and whether to call. They're not looking for everything you did. They're looking for **proof** that you can do the job, organized so they can find it without help.

You've built a lot. This lesson turns a repository full of work into a portfolio that proves all three pillars in under a minute.

## Do it

1. **Read your portfolio as a stranger would.** Open your repo on github.com in a private browser window. Set a one-minute timer. Start at the README and click wherever it leads. When the timer ends, write down: what does this person do, and what could they do on day one? If the answer is fuzzy, that's what this lesson fixes.

2. **Restructure the README** around proof, not chronology. Replace the module-by-module list with this shape:

   ```markdown
   # Your Name: Cloud Security Portfolio

   I build in AWS, design who gets access to what, and use AI to work faster
   without making it a security hole. Aiming for: [your target role].

   ## Start here (60 seconds)
   | If you want to see… | Look at | What it proves |
   |---|---|---|
   | An app I built and secured in AWS | [notes-app](notes-app/) | Serverless AWS, all in OpenTofu, least-privilege roles |
   | How I'd handle a breach | [The ci-deploy incident](incidents/) | Detection, containment, a blameless postmortem |
   | How I keep AI in a box | [My Claude Code policy](security/claude-policy/) | Managed settings, hooks, AI roles in IAM |
   | A security review I wrote | [Security review](security/review.md) | Threat model, findings, accepted risks |

   ## Everything else
   (A short table of the rest: logslayer, the hardened Linux VM, the
   container image, the networking project, the identity design, the AI
   usage policy.)

   ## How I work
   Two or three sentences on checking AI's work, and a link to your AI check log.
   ```

   Four rows in "Start here," no more. Pick the four that best match the job you want. A SOC applicant leads with the incident; a cloud engineer leads with the notes app.

3. **Make every project page stand alone.** For each project's own `README.md`, check it answers four questions in its first screen: **what** it is, **why** it matters, **what you did** (by hand vs. with Claude), and **what you learned**, ideally with a mistake. Fix any that don't.

4. **Clean up.** Delete practice files that don't prove anything (`hello.sh`, scratch notes). Check every link works. Make sure there are no secrets (run gitleaks from [Module 8](../08-security-concepts/06-secrets-management.md) one more time), no `terraform.tfstate`, no `.env`.

5. **Pin it.** On your GitHub profile, pin your portfolio repo. Add your target role and a one-line summary to your profile bio.

6. Commit and push.

## Break it

Hand your portfolio to someone who isn't technical, a friend or family member, and give them the same one-minute test. Ask them afterward: "What do I do? Would you trust me with something important?"

If they can't answer, a non-technical recruiter (who often screens before an engineer ever sees your work) can't either. Your "Start here" table and the first line of the README should make sense to someone who's never heard of IAM. Fix whatever confused them, then repeat the test with someone technical.

## With Claude

Ask Claude Code:

```text
Review my portfolio's README.md as a hiring manager for a junior cloud
security engineer role would, in about 60 seconds of attention. What do you
notice first? What's unclear? What would make you call me, and what might
make you skip me? Don't rewrite it.
```

**Check the work:** take only suggestions that are true to you. If Claude suggests claiming experience you don't have ("production experience," "led incidents"), ignore it. An interviewer will ask about every line, and your portfolio's strength is that every claim links to proof. Did it notice anything you can verify, like a broken link or a project with no README? Fix those.

## Check yourself

1. What does a hiring manager need to find in the first minute?
   <details><summary>Answer</summary>

   What you do, what job you want, and proof you can do it, in a few clear places they can click straight to.
   </details>

2. Why lead with different projects for different roles?
   <details><summary>Answer</summary>

   The first thing they see should match the job. A SOC manager wants detection and incident response; a cloud team wants infrastructure and identity.
   </details>

3. What four questions should each project page answer?
   <details><summary>Answer</summary>

   What it is, why it matters, what you did (by hand and with AI), and what you learned.
   </details>

## Go deeper

- [GitHub: managing your profile README](https://docs.github.com/en/account-and-profile/setting-up-and-managing-your-github-profile/customizing-your-profile/managing-your-profile-readme): a profile page that links straight to your portfolio.
