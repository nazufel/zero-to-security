# Module 7: Identity & Access (AWS IAM)

**Pillars:** 🪪 Identity · ☁️ Cloud · 🤖 AI

> 🚧 **Outline.** Lessons are being written. The checklist and plan below are final.

## Why this module matters

Attackers don't break in, they log in. Stolen credentials and over-broad permissions are behind a huge share of real breaches, and "broken access control" is #1 on the OWASP Top 10. Identity is the new perimeter. AWS IAM is free, so every lab in this module costs nothing.

## You're ready to move on when…

- [ ] You can read any IAM policy and say who can do what to which resource, and why a request was allowed or denied
- [ ] You can explain authentication vs. authorization
- [ ] You can name the kinds of AWS principals and when each is used
- [ ] You can design users, groups, and roles for a small team
- [ ] You can explain explicit deny > allow > implicit deny, and predict the result of a policy
- [ ] You can explain why a role, not a user with access keys, is the right "service account"
- [ ] You can assume a role from the CLI and find the event in CloudTrail
- [ ] You can explain the confused deputy problem and how External ID prevents it
- [ ] You can give an AI agent its own least-privilege role and explain every permission in it

## Lessons (planned)

1. **Identity 101:** authentication vs. authorization; Linux users, groups, and `sudo` revisited
2. **Principals:** root user, IAM users, IAM roles, federated users, AWS services. Opinion: humans never get long-lived access keys.
3. **Groups:** permissions go on groups, never directly on users. Gotchas: groups can't be nested and aren't principals.
4. **Policies:** identity-based, resource-based (S3 bucket policies), trust policies, permissions boundaries. JSON anatomy: Effect, Action, Resource, Condition. SCPs explained, not hands-on.
5. **Permissions and evaluation logic:** deny beats allow beats implicit deny; conditions such as require-MFA and source IP; a preview of tag-based access (ABAC)
6. **Service accounts:** in AWS they're roles, like the Lambda execution role and the EC2 instance profile. Why an IAM user with keys used as a service account is the #1 real-world finding.
7. **Impersonation:** `sts:AssumeRole`, temporary credentials, role chaining, the confused deputy and External ID, and tracing *who really did it* in CloudTrail
8. **AI agents are principals too:** Claude Code, MCP servers, and subagents act with credentials, so they get their own role, a trust policy, and an audit trail. *(OWASP LLM: Excessive Agency)*

> **Why no Identity Center labs?** On AWS's free plan, joining an AWS Organization ends your free credits immediately, and Identity Center normally needs one. You'll learn Identity Center and SCPs as "what you'll see at work." ([AWS Free Tier FAQs](https://aws.amazon.com/free/faqs/), **last verified:** 2026-10-27)

## Labs (all free)

- Build users, groups, and roles for a fictional team: dev, analyst, auditor
- **Break it:** write a policy, predict the result, then test it in the IAM Policy Simulator
- Assume a role from the CLI, then find the `AssumeRole` event in CloudTrail event history
- Validate policies with IAM Access Analyzer's policy checks
- **With Claude:** have Claude write a least-privilege policy for the notes app's Lambda, then prove it right or too broad with the simulator

## Practice

- **Challenges:** "This policy allows `s3:*` on `*` with a deny on one bucket. Can Alice read that bucket?" · "Find three problems in this trust policy."
- **Project:** an identity design for the notes app: principals, roles, trust relationships, and a diagram, all in OpenTofu. *(OWASP A01: Broken Access Control, A07: Authentication Failures)*

## Dig Deeper

- [flaws2.cloud](http://flaws2.cloud/): attacker and defender paths through real AWS IAM mistakes
