# Glossary

Plain-language definitions. Terms are added as lessons are written. Missing one? [Open an issue.](../../../issues/new?template=confusing.md)

| Term | Meaning | Module |
|---|---|---|
| **Agent (AI)** | An AI that can take actions, like running commands or editing files, not just answer questions | 1 |
| **AssumeRole** | Temporarily taking on an IAM role's permissions | 7 |
| **Blast radius** | How much damage a mistake or compromise can do. Least privilege shrinks it. | 1, 7 |
| **CIDR** | Notation for a range of IP addresses, like `10.0.0.0/24` | 4 |
| **CloudTrail** | AWS's audit log: who did what, when, from where | 9 |
| **Commit** | A saved snapshot of changes in Git | 0 |
| **Container** | A packaged app with just what it needs to run, isolated from the rest of the system | 5 |
| **CVE** | A public ID for a known vulnerability | 5 |
| **Digest** | A unique fingerprint of a container image. Unlike a tag, it can't be moved. | 5 |
| **DNS** | The system that turns names like `example.com` into IP addresses | 4 |
| **Excessive agency** | Giving an AI more power than its task needs. An OWASP LLM Top 10 risk. | 1, 8 |
| **Hallucination** | When AI states something false with confidence | 1 |
| **IaC (Infrastructure as Code)** | Defining cloud resources in code files instead of clicking in a console | 6 |
| **IAM** | Identity and Access Management: AWS's system for who can do what | 7 |
| **Incident** | Something broken or under attack right now | 0, 9 |
| **Least privilege** | Giving every person and program only the access it needs, nothing more | 7, 8 |
| **LLM** | Large language model, the kind of AI behind Claude | 1 |
| **MCP** | Model Context Protocol: a standard way to connect AI to tools and data | 1, 6 |
| **MFA** | Multi-factor authentication: something you know plus something you have | 0, 7 |
| **OIDC** | A login standard that lets systems like GitHub Actions get short-lived cloud credentials with no stored keys | 8 |
| **OpenTofu** | A free, open-source tool for Infrastructure as Code | 6 |
| **OWASP** | A nonprofit that publishes widely used security guidance, including the Top 10 lists | 1, 8 |
| **Phishing** | A fake message designed to trick someone into clicking, paying, or giving up a password | 9 |
| **Port** | A numbered door on a computer that a network service listens on, like 22 for SSH | 4 |
| **Postmortem** | A blameless write-up of what happened in an incident and how to prevent it | 9 |
| **Principal** | Anyone or anything that can make a request in AWS: a user, role, or service | 7 |
| **Prompt injection** | Tricking an AI with instructions hidden in data it reads | 1, 8 |
| **Role (IAM)** | An identity with no permanent password or keys. You assume it to get temporary credentials. | 7 |
| **SBOM** | Software Bill of Materials: a list of everything inside a piece of software | 5 |
| **Security group** | A stateful firewall attached to an AWS resource | 6 |
| **SOC** | Security Operations Center: the team that watches for and responds to attacks | 0, 9 |
| **SSH** | Secure Shell: an encrypted way to log in to a remote machine | 2 |
| **Subnet** | A slice of a network's address range | 4 |
| **Ticket** | A tracked record of a request or problem | 0 |
| **VM (virtual machine)** | A whole computer running as software inside your real one | 2 |
| **Zero trust** | Never trust a request because of where it comes from; verify every time | 8 |
