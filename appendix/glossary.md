# Glossary

Plain-language definitions. Terms are added as lessons are written. Missing one? [Open an issue.](../../../issues/new?template=confusing.md)

| Term | Meaning | Module |
|---|---|---|
| **ABAC** | Attribute-based access control: granting access by tags, like "developers can change functions tagged team = notes" | 7 |
| **Agent (AI)** | An AI that can take actions, like running commands or editing files, not just answer questions | 1 |
| **AMI** | A disk image for an EC2 instance, like Ubuntu 26.04 | 6 |
| **API Gateway** | AWS's front door for APIs: takes HTTPS requests and passes them to Lambda | 6 |
| **AssumeRole** | Temporarily taking on an IAM role's permissions | 7 |
| **Authentication** | Proving who you are (password, key, MFA). Fails with 401. | 7 |
| **Authorization** | Deciding what you're allowed to do (policies, groups). Fails with 403. | 7 |
| **Blast radius** | How much damage a mistake or compromise can do. Least privilege shrinks it. | 1, 7 |
| **Certificate** | A file that proves a site's identity, vouched for by a certificate authority. Browsers warn when one is expired, untrusted, or for a different name. | 4 |
| **CIDR** | Notation for a range of IP addresses, like `10.0.0.0/24` | 4 |
| **CLAUDE.md** | A project file of instructions Claude Code reads at the start of every session. Guidance, not enforcement. | 1, 3 |
| **CloudFront** | AWS's content delivery network. Serves a private bucket's files publicly over HTTPS. | 6 |
| **CloudTrail** | AWS's audit log: who did what, when, from where | 9 |
| **Command injection** | When input is run as part of a shell command, letting an attacker run their own commands. Prevented by passing arguments as a list. | 3 |
| **Commit** | A saved snapshot of changes in Git | 0 |
| **Confused deputy** | A trusted service tricked into using its access for the wrong customer. Prevented by an External ID. | 7 |
| **Container** | A packaged app with just what it needs to run, isolated from the rest of the system | 5 |
| **CORS** | Browser rules for which websites may call an API on another domain | 6 |
| **CVE** | A public ID for a known vulnerability | 5 |
| **Data event** | A CloudTrail record of reading or writing data, like an S3 object. Not logged by default. | 6, 9 |
| **Default gateway** | The router a machine sends traffic to when the destination isn't on its own subnet | 4 |
| **Defense in depth** | Several layers of controls, so when one fails another still limits the damage | 1, 8 |
| **Dependency** | A package your code needs. Transitive dependencies are the packages your dependencies need. | 3, 5 |
| **DHCP** | The service that hands a device its IP address, gateway, and DNS servers when it joins a network | 4 |
| **Digest** | A unique fingerprint of a container image. Unlike a tag, it can't be moved. | 5 |
| **DNS** | The system that turns names like `example.com` into IP addresses | 4 |
| **DynamoDB** | AWS's serverless database | 6 |
| **EC2** | AWS's virtual servers | 6 |
| **Encoding** | Changing data's format, like base64. Reversible by anyone. Not security. | 1, 4 |
| **Encryption** | Scrambling data so only someone with the key can read it | 4, 8 |
| **Excessive agency** | Giving an AI more power than its task needs. An OWASP LLM Top 10 risk. | 1, 8 |
| **Explicit deny** | A Deny statement in a policy. Always wins over any Allow. | 7 |
| **Extended thinking** | A mode where an AI model reasons step by step before answering. Slower, but better on hard, multi-step problems. | 1 |
| **External ID** | A shared value a third party must send to assume your role, preventing the confused deputy problem | 7 |
| **Fail open / fail closed** | What a security check does when it hits an error: allow (open, dangerous) or deny (closed, safe) | 3 |
| **Firewall** | Software that decides which network connections are allowed in or out. Ubuntu's is `ufw`. | 2, 4 |
| **Hallucination** | When AI states something false with confidence | 1 |
| **Hash** | A one-way fingerprint of data. Used to store passwords and to check files haven't changed. | 4 |
| **Hook (Claude Code)** | A script that runs automatically before or after Claude Code acts, and can block the action | 1, 8 |
| **IaC (Infrastructure as Code)** | Defining cloud resources in code files instead of clicking in a console | 6 |
| **IAM** | Identity and Access Management: AWS's system for who can do what | 7 |
| **Image (container)** | A packaged template for containers: an app plus everything it needs. A container is a running copy of one. | 5 |
| **IMDSv2** | The safer version of the EC2 metadata service. Requires a token, which blocks a common credential-theft trick. | 6 |
| **Implicit deny** | AWS's default: anything not explicitly allowed is denied | 7 |
| **Incident** | Something broken or under attack right now | 0, 9 |
| **Instance profile** | The wrapper that delivers an IAM role to an EC2 instance | 7 |
| **Journal** | Where systemd services on Linux write their logs. Read it with `journalctl`. | 2 |
| **JSON** | A plain-text data format that almost every tool and API speaks. Looks like a Python dictionary. | 3 |
| **Key pair (SSH)** | A private key that stays with you and a public key you put on servers. Logs you in with nothing guessable sent over the network. | 2 |
| **Knowledge cutoff** | The date an AI model's training data ends. It can't know later events unless it searches. | 1 |
| **Lambda** | AWS's service for running code on request, with no server to manage | 6 |
| **Least privilege** | Giving every person and program only the access it needs, nothing more | 7, 8 |
| **LLM** | Large language model, the kind of AI behind Claude | 1 |
| **Lockfile** | A file, like `uv.lock`, that pins the exact version and hash of every package so every install is identical | 3, 5 |
| **Managed settings** | An organization-wide Claude Code policy that individual users can't override | 1, 8 |
| **MCP** | Model Context Protocol: a standard way to connect AI to tools and data | 1, 6 |
| **MFA** | Multi-factor authentication: something you know plus something you have | 0, 7 |
| **Minimal image** | A container image with only what the app needs to run, often with no shell or package manager | 5 |
| **Multi-stage build** | A Dockerfile that builds in one image and copies only the result into a smaller one to ship | 5 |
| **NACL** | A stateless firewall on an AWS subnet, with numbered allow and deny rules | 6 |
| **OIDC** | A login standard that lets systems like GitHub Actions get short-lived cloud credentials with no stored keys | 8 |
| **OpenTofu** | A free, open-source tool for Infrastructure as Code | 6 |
| **OWASP** | A nonprofit that publishes widely used security guidance, including the Top 10 lists | 1, 8 |
| **Package manager** | A tool that downloads, installs, and updates software from a trusted source, like `apt` on Ubuntu | 2, 3 |
| **Packet capture** | A recording of network traffic, made with tools like `tcpdump` and read in Wireshark | 4, 9 |
| **Parameter Store** | An AWS Systems Manager feature for storing settings and secrets (as encrypted SecureStrings) | 6 |
| **Permissions boundary** | A cap on the most a user or role can ever be allowed, whatever its other policies say | 7 |
| **Phishing** | A fake message designed to trick someone into clicking, paying, or giving up a password | 9 |
| **Pipe** | The `\|` character: sends one command's output into the next command | 2 |
| **Port** | A numbered door on a computer that a network service listens on, like 22 for SSH | 4 |
| **Postmortem** | A blameless write-up of what happened in an incident and how to prevent it | 9 |
| **Principal** | Anyone or anything that can make a request in AWS: a user, role, or service | 7 |
| **Prompt injection** | Tricking an AI with instructions hidden in data it reads | 1, 8 |
| **Redact** | Remove or replace sensitive details, like secrets or personal data, before sharing something | 1 |
| **Regression test** | A test for a bug you already fixed, so it can't quietly come back | 3 |
| **Role (IAM)** | An identity with no permanent password or keys. You assume it to get temporary credentials. | 7 |
| **Root** | The all-powerful admin account on Linux. Ignores file permissions. | 2 |
| **S3** | AWS's object storage: files (objects) in buckets | 6 |
| **Salt** | A random value added to each password before hashing, so identical passwords get different hashes | 4 |
| **SBOM** | Software Bill of Materials: a list of everything inside a piece of software | 5 |
| **Security group** | A stateful firewall attached to an AWS resource | 6 |
| **Service** | A program that runs in the background, like a web or SSH server. Managed with `systemctl`. | 2 |
| **Service account** | An identity for software, not a person. In AWS, it should be a role. | 7 |
| **Shared responsibility model** | AWS secures the cloud itself; you secure what you put in it and how you configure it | 6 |
| **Signature (image)** | Proof of who built an image, checked with cosign against an identity you trust | 5 |
| **Skill (Claude Code)** | Packaged instructions for a repeatable task, stored in a `SKILL.md` file | 1, 9 |
| **Snapshot** | A saved state of a VM or disk that you can return to later | 2, 9 |
| **SOC** | Security Operations Center: the team that watches for and responds to attacks | 0, 9 |
| **SQS** | AWS's message queue | 6 |
| **SSH** | Secure Shell: an encrypted way to log in to a remote machine | 2 |
| **Standard library** | The modules that come with Python, like `json` and `ipaddress`. Nothing extra to install or trust. | 3 |
| **State (OpenTofu)** | OpenTofu's record of what it manages. Can contain secrets. Never commit it. | 6 |
| **Subagent** | A helper AI agent with its own instructions and a limited set of tools, for one job | 1, 9 |
| **Subnet** | A slice of a network's address range | 4 |
| **sudo** | Runs one command as root. Who can use it is one of the most important questions on a server. | 2 |
| **Tag (image)** | A movable, human-friendly label for an image, like `latest`. Unlike a digest, it can be repointed. | 5 |
| **TCP / UDP** | The two ways to send data. TCP is reliable and ordered (web, SSH). UDP is fast with no guarantees (DNS, video). | 4 |
| **Ticket** | A tracked record of a request or problem | 0 |
| **TLS** | The encryption behind HTTPS. Also checks the site's certificate. | 4 |
| **Trust policy** | The policy on a role that says who can assume it | 7 |
| **Virtual environment** | A private folder of Python packages for one project | 3 |
| **VM (virtual machine)** | A whole computer running as software inside your real one | 2 |
| **Volume** | A host folder or file mounted into a container. Mount read-only (`:ro`) unless it must write. | 5 |
| **VPC** | Your own private network in AWS | 6 |
| **XSS (cross-site scripting)** | Injecting code into a web page that runs in other visitors' browsers | 6 |
| **Zero trust** | Never trust a request because of where it comes from; verify every time | 8 |
