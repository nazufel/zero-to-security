# Project: a security review of the notes app

**Pillars:** ☁️ Cloud · 🪪 Identity · 🤖 AI

## Why this matters

A security review is the core deliverable of security engineering: what's wrong, how bad, what was fixed, and what's accepted on purpose. You've done every piece of one across this module. Now you put it together the way you'd hand it to a team lead or an auditor, with your AI policy and a working pipeline as evidence. It's also the single strongest page in your portfolio.

## What to build

```text
my-security-portfolio/
├── .github/
│   ├── workflows/notes-app.yml     # lessons 13–14
│   └── dependabot.yml              # lesson 8
├── notes-app/
│   ├── infra/  (hardened, with .checkov.yaml)
│   └── pipeline/main.tf
└── security/
    ├── review.md                   # this project
    ├── before-after.png            # or .md: the architecture, before and after
    ├── claude-policy/              # lesson 12: managed settings and hook
    └── foundations.md  threat-model.md  owasp-top-10.md  securing-ai.md  ...
```

## Steps

1. **Write `security/review.md`** with these sections:

   - **Summary:** three sentences a manager would read. What the app is, how secure it is now, and the biggest remaining risk.
   - **Scope:** what you reviewed (the code, the infrastructure, the pipeline, the AI setup) and what you didn't.
   - **Findings:** a table of everything you found and fixed in this module, with severity and evidence:

     | # | Finding | Severity | Fixed in | Evidence |
     |---|---|---|---|---|
     | 1 | Delete route trusted a shared token, with no identity | High | Lesson 3 | `api.tf` `AWS_IAM` route; the three-way Break it |
     | 2 | NACL allowed RDP (3389) from anywhere | Medium | Lesson 14 | `vpc.tf`, Checkov `CKV_AWS_231` |
     | 3 | SSH open to the internet (by IP) | Medium | Lesson 7 | No inbound rules; `nc` timeout |
     | ... | | | | |

     Include at least ten, from every part of the module: least privilege, segmentation, encryption, secrets, patching, the threat model's gaps, and the AI setup.

   - **Accepted risks:** the important entries from `.checkov.yaml` and your threat model, with reasons. Link to the files.
   - **AI in a box:** your managed-settings policy (lesson 12), what each layer stops, and the two hook gaps you found.
   - **The pipeline:** what it checks, how it authenticates, and the two things you proved it catches (a secret, an over-permissive policy). Link a passing run and the two failing runs in the Actions tab.
   - **What I'd do next:** the top three remaining risks and how you'd address them. (Module 9's logging and alerting should be on this list.)

2. **Draw before and after.** Two versions of your Module 6 architecture diagram: before this module, and now. Mark what changed: the delete route's IAM auth, port 22 gone, Session Manager, TLS-only bucket, the pipeline with OIDC, Claude's roles inside the managed policy.

3. **Prove it's live.** Push a trivial change to `main` (a README edit), approve the deploy, and confirm the site works. Add the run's link to the review.

4. **Commit, and tear down:**

   ```bash
   git add security/ notes-app/ .github/
   git commit -m "Security review of the notes app"
   git push
   cd notes-app/infra && tofu destroy
   ```

   (The pipeline and state bucket stay. The next push to `main` redeploys the app after your approval.)

## With Claude

Ask Claude Code to review your review:

```text
Read security/review.md and check every claim against the files it links to
and the code in notes-app/ and .github/. List any claim that the evidence
doesn't support, any finding I've rated too low or too high, and any risk
that's missing entirely. Don't change files.
```

**Check the work:** for each unsupported claim, decide if Claude's right and fix the review. For each missing risk, check whether it's real. For each severity change, make it argue the case with likelihood and impact (lesson 9). A security review is a document people **act on**, so every line must be true.

## Done when

- [ ] `review.md` has a summary, scope, at least ten findings with evidence, accepted risks, the AI section, the pipeline section, and next steps
- [ ] Every claim links to a file, a command output, or a pipeline run
- [ ] The before/after diagram shows what changed
- [ ] The pipeline passes on `main`, and you've shown it failing on a secret and on an over-permissive policy
- [ ] Your managed-settings policy and hook are in `security/claude-policy/`
- [ ] You can walk an interviewer through the review in five minutes, starting from the summary
