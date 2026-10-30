# Dig Deeper

**Optional.** None of this is required for an entry-level job. These topics show up on job postings and are worth exploring once the core course feels solid, or when a posting you want asks for one.

When you list Dig Deeper work on your resume, be honest: "hands-on lab experience with Kubernetes (kind)," not "Kubernetes expert." Interviewers respect the first and will test the second.

## Start with the track for your target role

| Role | Track | What you'll do |
|---|---|---|
| Help desk / IT support | [Okta](okta/) | User lifecycle, resets with caller verification, passkeys, the System Log, and SSO into AWS |
| SOC analyst | [Elastic](elastic/) | Run a SIEM, ingest your own logs, search with ES\|QL, build dashboards and detection rules |
| Junior cloud / security engineer | [Kubernetes](kubernetes/) | RBAC, service accounts, network policies, pod security, and reviewing AI-written manifests |

## More topics

| Topic | Builds on | Free way to practice |
|---|---|---|
| Active Directory | Linux, Identity | Samba AD in your VM, or Windows Server's free evaluation |
| Email security (SPF, DKIM, DMARC) | Networking (DNS) | `dig` against real domains |
| Symmetric vs. asymmetric encryption | Networking (crypto basics), Linux (SSH keys) | OpenSSL in your VM |
| Common attacks field guide | Security Concepts | Reading, with links to the defenses you built |
| OWASP Juice Shop | Security Concepts (OWASP Top 10) | Juice Shop in Docker, locally |
| Vulnerability management (CVE, CVSS, CISA KEV) | Containers (scans) | Your own Grype results |
| OWASP Top 10 for Agentic Applications | AI Foundations, Security Concepts | Your own Claude Code setup |
| Backups and recovery | Cloud | S3 versioning |
| Sigma detection rules | Incident Response, Elastic | Convert your Elastic rules to Sigma |
| Threat intel basics | Incident Response | Free lookup tools |
| GRC (NIST CSF, CIS Controls, compliance) | Security Concepts | Mapping your own app to a framework |
| Regex for log hunting | Linux, Python | `grep -E` and Python's `re` |
| Endpoint security and EDR concepts | Incident Response | Reading |
| Windows event logs for SOC | Incident Response | Sample logs |

The three role tracks are complete. The rest are coming.
