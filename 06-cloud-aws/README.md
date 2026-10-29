# Module 6: Cloud (AWS)

**Pillars:** ☁️ Cloud · 🤖 AI

> 🚧 **Outline.** Lessons are being written. The checklist and plan below are final.

## Why this module matters

Most of what you'll defend runs in someone else's data center. If you can look at any application and say "that part is S3, that part is Lambda, the secrets live here," you can understand where it's weak. This module teaches you to turn an app architecture into cloud services, and to build them as code.

## Opinions

- **AWS.** The biggest cloud, and the one on the most job postings.
- **Serverless first:** API Gateway, Lambda, and DynamoDB stay inside free limits and avoid the classic beginner bill killers (NAT Gateways, idle databases, forgotten servers).
- **[OpenTofu](https://opentofu.org/) for everything.** You click through the console once to see a service, then define it as code. Your infrastructure code doubles as your inventory: you can't protect what you don't know you have.
- **Don't create your AWS account until this module.** Read [AWS cost safety](../appendix/aws-cost-safety.md) first.

## You're ready to move on when…

- [ ] You've set up an AWS account safely: root MFA, a budget alert, a non-root admin user, and a chosen region
- [ ] You can explain the shared responsibility model with an example
- [ ] You can map front end, back end, data store, secret store, blob store, and message broker to AWS services
- [ ] You can explain a VPC, public vs. private subnets, security groups, and NACLs
- [ ] You can write, plan, apply, and destroy infrastructure with OpenTofu
- [ ] You can explain why OpenTofu state files must never be committed
- [ ] You can use the AWS CLI and `boto3` from Python
- [ ] You've deployed the notes app, drawn its architecture, and torn it down
- [ ] You can connect Claude to AWS through MCP using its own limited role, never your keys

## Architecture → AWS

| App part | AWS service |
|---|---|
| Front end | S3 static site + CloudFront |
| Back end | API Gateway + Lambda (Python) |
| Data store | DynamoDB |
| Secret store | SSM Parameter Store (SecureString). Secrets Manager explained, not used. |
| Blob store | S3 |
| Message broker | SQS (SNS explained) |
| Network | VPC, subnets, security groups, NACLs |
| One server | A single EC2 instance, so your Linux skills transfer |

## Lessons (planned)

1. **Account setup done right:** root MFA, budget alert at $1, an admin IAM user in a group, region choice, the end-of-session cleanup checklist
2. **Shared responsibility:** what AWS secures and what you secure
3. **OpenTofu basics:** providers, resources, variables, outputs, `plan`, `apply`, `destroy`. Local state, gitignored, and why state leaks secrets
4. **Storage:** S3 (and why public buckets make headlines)
5. **Compute:** Lambda in Python, plus one EC2 instance you SSH into
6. **APIs:** API Gateway in front of Lambda
7. **Data:** DynamoDB
8. **Secrets:** Parameter Store; rip the hard-coded key out of your code
9. **Messages:** SQS
10. **Networking in AWS:** VPC, subnets, security groups, NACLs (Module 4, renamed)
11. **AWS CLI and `boto3`:** `logslayer` learns to read CloudTrail
12. **Claude and AWS:** MCP, and giving AI its own least-privilege role

Every lesson follows **Console → Code → Claude**: click through once, define it in OpenTofu, then have Claude extend it while you review the diff and the `tofu plan`.

## Practice

- **Project:** deploy the notes app entirely in OpenTofu, draw its architecture diagram, and commit both. `tofu destroy` when you're done for the day.

## Dig Deeper

- Backups and recovery: S3 versioning, RTO and RPO
- [AWS Skill Builder](https://skillbuilder.aws/) free courses
