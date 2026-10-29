# Module 7: Identity & Access (AWS IAM)

**Pillars:** 🪪 Identity · ☁️ Cloud · 🤖 AI

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

## Lessons

1. [Identity 101](01-identity-101.md): authentication vs. authorization; Linux users, groups, and `sudo` revisited
2. [Principals](02-principals.md): root user, IAM users, IAM roles, federated users, AWS services. Opinion: humans never get long-lived access keys.
3. [Groups](03-groups.md): permissions go on groups, never directly on users. Gotchas: groups can't be nested and aren't principals.
4. [Policies](04-policies.md): identity-based, resource-based, trust policies, permissions boundaries, and SCPs explained. JSON anatomy, and Access Analyzer validation.
5. [Permissions and evaluation logic](05-evaluation-logic.md): deny beats allow beats implicit deny; conditions such as require-MFA; a preview of ABAC. Predict, then prove with the Policy Simulator.
6. [Service accounts](06-service-accounts.md): in AWS they're roles, like the Lambda execution role and the EC2 instance profile
7. [Impersonation](07-impersonation.md): `sts:AssumeRole`, temporary credentials, the confused deputy and External ID, and tracing *who really did it* in CloudTrail
8. [AI agents are principals too](08-ai-agents-are-principals.md): a role per AI task, a trust policy, explicit denies, and an audit trail. *(OWASP LLM: Excessive Agency)*

> **Why no Identity Center labs?** On AWS's free plan, joining an AWS Organization ends your free credits immediately, and Identity Center normally needs one. You'll learn Identity Center and SCPs as "what you'll see at work." ([AWS Free Tier FAQs](https://aws.amazon.com/free/faqs/), **last verified:** 2026-10-27)

## Labs (all free)

All of these are in the lessons:

- Users, groups, and roles for a fictional team: developers, analysts, auditors ([lesson 3](03-groups.md))
- **Break it:** write a policy, predict the result, then test it in the IAM Policy Simulator ([lesson 5](05-evaluation-logic.md))
- Assume a role from the CLI, then find the `AssumeRole` event in CloudTrail ([lesson 7](07-impersonation.md))
- Validate policies with IAM Access Analyzer ([lesson 4](04-policies.md) and the project)
- **With Claude:** have Claude write least-privilege policies, then prove them right or too broad with the simulator ([lessons 4](04-policies.md), [5](05-evaluation-logic.md), and [8](08-ai-agents-are-principals.md))

## Practice

- [Quiz](quiz.md), including the challenges: "This policy allows `s3:*` on `*` with a deny on one bucket. Can Alice read that bucket?" · "Find three problems in this trust policy." · [flaws2.cloud](http://flaws2.cloud/)
- [Project: an identity design for the notes app](project.md): principals, roles, trust relationships, a diagram, and tests, all in OpenTofu. *(OWASP A01: Broken Access Control, A07: Authentication Failures)*

## Dig Deeper

- [flaws2.cloud](http://flaws2.cloud/): attacker and defender paths through real AWS IAM mistakes
