# Module 8: Security Concepts

**Pillars:** ☁️ Cloud · 🪪 Identity · 🤖 AI

## Why this module matters

You've built an app in the cloud and designed who can touch it. Now you secure it end to end, including the AI that helped build it and the pipeline that ships it. This is where the three pillars meet.

## You're ready to move on when…

- [ ] You can explain the CIA triad, defense in depth, and least privilege with examples from your own app
- [ ] You can explain zero trust and point to where your app applies it
- [ ] You can segment your app's network and justify every open path
- [ ] You can encrypt data at rest and in transit, and say what each protects against
- [ ] You can replace SSH with SSM Session Manager and explain why port 22 is closed
- [ ] You can threat-model an app with STRIDE
- [ ] You can map each OWASP Top 10 risk to where you defended against it in this course
- [ ] You can map the controls around your AI to the OWASP Top 10 for LLM Applications
- [ ] You can write a Claude Code hook and a managed-settings policy that keep AI in a box
- [ ] You can build a CI/CD pipeline that tests, scans, and deploys with no stored AWS keys

## Lessons

1. [Foundations](01-foundations.md): CIA triad, defense in depth, authentication vs. authorization, MFA
2. [Least privilege](02-least-privilege.md): tighten the notes app's Lambda roles to what the code uses
3. [Zero trust](03-zero-trust.md): never trust, always verify. The delete route moves from a shared token to signed requests.
4. [Network segmentation](04-network-segmentation.md): tiers chained by security groups, and identity segmentation for serverless
5. [Encryption at rest and in transit](05-encryption.md): KMS key types, and a TLS-only bucket
6. [Secrets management](06-secrets-management.md): finish removing every secret, and scan history with gitleaks
7. [Closing port 22](07-closing-port-22.md): SSM Session Manager instead of SSH
8. [Vulnerability and patch management](08-vulnerability-management.md): CVSS, EPSS, and KEV; Dependabot for pinned dependencies
9. [Threat modeling with STRIDE](09-threat-modeling.md): on your own architecture diagram. Then have Claude threat-model it, and critique Claude's version.
10. [The OWASP Top 10](10-owasp-top-10.md): you've already defended against most of it, with evidence for each
11. [Securing AI](11-securing-ai.md): the OWASP Top 10 for LLM Applications, applied to your own setup, with a planted prompt injection
12. [Keeping AI in a box](12-ai-in-a-box.md): Claude Code hooks (block risky commands), and an organization-wide managed-settings policy
13. [A secure delivery pipeline](13-secure-pipeline.md): GitHub Actions (free on public repos), deploying to AWS with OIDC, no stored keys
14. [Scanning infrastructure code](14-scanning-infrastructure-code.md): catch misconfigurations before `tofu apply`, and triage the findings

## The OWASP Top 10:2025, mapped to this course

> **Last verified:** 2026-10-27 ([OWASP Top 10:2025](https://owasp.org/Top10/2025/))

| Risk | Where you met it |
|---|---|
| A01 Broken Access Control | Identity (Module 7) |
| A02 Security Misconfiguration | OpenTofu and IaC scanning (Modules 6, 8) |
| A03 Software Supply Chain Failures | Chainguard, digest pinning, the Trivy story (Module 5) |
| A04 Cryptographic Failures | Crypto basics and TLS (Modules 4, 8) |
| A05 Injection | Never trust input (Module 3) |
| A06 Insecure Design | Threat modeling (Module 8) |
| A07 Authentication Failures | MFA and IAM (Module 7) |
| A08 Software or Data Integrity Failures | Signatures and pinned CI actions (Modules 5, 8) |
| A09 Security Logging and Alerting Failures | CloudTrail and monitoring (Module 9) |
| A10 Mishandling of Exceptional Conditions | Python errors (Module 3) |

## AI in a box, mapped to the OWASP Top 10 for LLM Applications

> "Excessive agency" is OWASP's name for giving AI more power than it needs. The fix is the same as for any junior engineer: least privilege, access controls, network controls, segmentation, and an audit trail.

| Box layer | Built in | Reduces |
|---|---|---|
| VM sandbox | Module 2 | Excessive agency, sensitive information disclosure |
| Containers | Module 5 | Excessive agency |
| Network controls | Modules 4, 6 | Excessive agency, data exfiltration |
| Its own IAM role | Module 7 | Excessive agency |
| Hooks and managed settings | Module 8 | Prompt injection impact, excessive agency |
| Audit logs | Module 9 | Detecting all of the above |

## The secure pipeline

Built in [lessons 13](13-secure-pipeline.md) and [14](14-scanning-infrastructure-code.md):

1. Test `logslayer`
2. Scan for secrets with gitleaks, build the Chainguard image, and scan it with Grype
3. Scan the infrastructure code with Checkov
4. `tofu plan` as a read-only role, then require a human approval
5. `tofu apply` through GitHub's OIDC login: no AWS keys stored anywhere
6. Every third-party action pinned by commit SHA (remember Trivy)

**Break it:** commit a fake secret and an over-permissive IAM policy. Watch the pipeline catch both.

## Practice

- [Quiz](quiz.md), with the challenge: [flaws.cloud](http://flaws.cloud/)
- [Project: a security review of the notes app](project.md): findings, fixes, and a before/after diagram, plus your managed-settings policy and the working pipeline
- Reference files: [the workflow](reference/notes-app.yml), [the hook](reference/block-risky.sh), and [the hardened notes app](../06-cloud-aws/reference/notes-app/)

## Dig Deeper

- [OWASP Juice Shop](https://owasp.org/www-project-juice-shop/) in Docker: break the OWASP Top 10 yourself
- Common attacks field guide
- Vulnerability management: CVE, CVSS, and CISA's Known Exploited Vulnerabilities list
- GRC: NIST CSF, CIS Controls, and what SOC 2, PCI, HIPAA, and GDPR mean
- [OWASP Top 10 for Agentic Applications](https://genai.owasp.org/)
