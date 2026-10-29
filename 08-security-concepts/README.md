# Module 8: Security Concepts

**Pillars:** ☁️ Cloud · 🪪 Identity · 🤖 AI

> 🚧 **Outline.** Lessons are being written. The checklist and plan below are final.

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

## Lessons (planned)

1. **Foundations:** CIA triad, defense in depth, authentication vs. authorization, MFA
2. **Least privilege:** tighten the notes app's Lambda role
3. **Zero trust:** never trust, always verify, applied to your app
4. **Network segmentation:** private subnets and security groups
5. **Encryption at rest and in transit:** KMS and TLS
6. **Secrets management:** finish removing every hard-coded secret
7. **Closing port 22:** SSM Session Manager instead of SSH
8. **Vulnerability and patch management:** acting on your scan results
9. **Threat modeling with STRIDE:** on your own architecture diagram. Then have Claude threat-model it, and critique Claude's version.
10. **The OWASP Top 10:** you've already defended against most of it (see the map below)
11. **Securing AI:** the OWASP Top 10 for LLM Applications, applied to your own setup
12. **Keeping AI in a box:** Claude Code hooks (block risky commands), and an organization-wide managed-settings policy (allowed tools, blocked commands)
13. **A secure delivery pipeline:** GitHub Actions (free on public repos), deploying to AWS with OIDC, no stored keys
14. **Scanning infrastructure code:** catch misconfigurations before `tofu apply`

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

1. Lint and test `logslayer`
2. Build the Chainguard image and scan it with Grype
3. `tofu plan`, scan the infrastructure code, then require a human approval
4. `tofu apply` through GitHub's OIDC login: no AWS keys stored anywhere
5. Every third-party action pinned by commit SHA (remember Trivy)

**Break it:** commit a fake secret and an over-permissive IAM policy. Watch the pipeline catch both.

## Practice

- **Challenge:** [flaws.cloud](http://flaws.cloud/)
- **Project:** a security review of the notes app: findings, fixes, and a before/after diagram, plus your managed-settings policy and the working pipeline

## Dig Deeper

- [OWASP Juice Shop](https://owasp.org/www-project-juice-shop/) in Docker: break the OWASP Top 10 yourself
- Common attacks field guide
- Vulnerability management: CVE, CVSS, and CISA's Known Exploited Vulnerabilities list
- GRC: NIST CSF, CIS Controls, and what SOC 2, PCI, HIPAA, and GDPR mean
- [OWASP Top 10 for Agentic Applications](https://genai.owasp.org/)
