# Project: an identity design for the notes app

**Pillars:** 🪪 Identity · ☁️ Cloud · 🤖 AI

## Why this matters

"Who can do what in this system, and why?" is the question behind **OWASP A01, Broken Access Control**, and **A07, Authentication Failures**. Most teams can't answer it for their own apps. You'll answer it for yours, in code, with a diagram, and with tests that prove the answer is true. That's an identity review, and it's real work that cloud security engineers do every week.

## What to build

```text
notes-app/
├── infra/
│   ├── team.tf  instance_profile.tf  vendor.tf  claude.tf   # from the lessons
│   └── test-team-access.sh                                  # from lesson 5
└── identity/
    ├── README.md        # the design: principals, roles, trust, decisions
    └── diagram.png      # or .md: who can become what, and what each can do
```

## Steps

1. **Inventory every principal.** In `notes-app/identity/README.md`, make one table covering every identity in your account that touches the notes app:

   ```markdown
   | Principal | Kind | Who or what can become it | What it can do | Why |
   |---|---|---|---|---|
   | admin | IAM user | You, with password + MFA | Everything | Setup and break-glass only |
   | notes-lambda | Role | The Lambda service | 4 DynamoDB actions on one table, read one parameter, send to one queue | Serve the API |
   | ... | | | | |
   ```

   Include: `admin`, both Lambda roles, the lab server role, the three team groups, `vendor-auditor`, both Claude roles, and the AWS service-linked roles (as one row).

2. **Draw the trust relationships.** For every role: an arrow from who can assume it, to the role, to what it can reach. Use [draw.io](https://www.drawio.com/), paper, or text. Label each arrow with its condition, if it has one ("External ID required," "admin user only").

3. **Validate every policy you wrote.** For each inline policy and trust policy in your `.tf` files, run Access Analyzer:

   ```bash
   aws iam get-role-policy --role-name notes-lambda --policy-name notes-app-access --query PolicyDocument > /tmp/p.json
   aws accessanalyzer validate-policy --policy-type IDENTITY_POLICY --policy-document file:///tmp/p.json \
     --query 'findings[].[findingType,issueCode]' --output table
   ```

   Record the result for each in the README. Fix any `SECURITY_WARNING` or `ERROR`, or write down why it's acceptable (like `lambda:ListFunctions` needing `*`).

4. **Prove it with tests.** Extend `test-team-access.sh` from [lesson 5](05-evaluation-logic.md) to cover the roles too: for every principal, at least one action it **should** be able to do and one it **shouldn't**. Include:

   - `notes-lambda` **can't** `dynamodb:DeleteTable`
   - the lab server **can't** `s3:DeleteObject`
   - `claude-notes-debugger` **can't** `ssm:GetParameter` (explicit deny)
   - `practice-ana` **can't** `dynamodb:PutItem`

   Run it and paste the output in the README. Then break one policy and show the test catching it.

5. **Write down three decisions**, one paragraph each, in the README. For example:

   - Why the delete route's admin token is a stopgap, not real authentication (lesson 1)
   - Why developers who can update Lambda code can effectively read notes, and what you'd do about it (lesson 3)
   - Why Claude gets two roles instead of one (lesson 8)

6. **Commit, and destroy:**

   ```bash
   cd ~/my-security-portfolio
   git add notes-app/
   git commit -m "Identity design for the notes app"
   git push
   cd notes-app/infra && tofu destroy
   ```

## With Claude

Ask Claude Code to attack your design, as a reviewer:

```text
Read notes-app/infra/*.tf and notes-app/identity/README.md. Act as an
attacker who has stolen the credentials of one principal. For each
principal, what's the worst thing they could do, and is there any path to
gaining more access (privilege escalation)? Don't change files.
```

**Check the work:** for each escalation path Claude claims, prove it or disprove it with the policy simulator. Two real ones to look for: developers updating Lambda code to act as the function's role, and anything that allows `iam:PassRole` or changing a role's policies. If Claude claims an escalation that the simulator shows is denied, it's wrong. If it finds one you missed, add it to the README with your fix.

## Done when

- [ ] Every principal is in the table, with who can become it and why it exists
- [ ] The diagram shows every trust relationship and its conditions
- [ ] Every policy you wrote passes Access Analyzer, or has a written reason
- [ ] `test-team-access.sh` passes, and you've shown it failing on a broken policy
- [ ] You can answer "who can delete a note, and how do you know?" out loud, pointing to the code and a test
