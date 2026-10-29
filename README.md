# Zero to Security

**A free, hands-on, opinionated path from "I know what a computer is" to your first job in security.**

Target roles: **help desk / IT support**, **SOC analyst**, **junior cloud or security engineer**.

---

## Why this course exists

You've heard that AI is coming for jobs. In a lot of fields, that's partly true.

Security is different, for now. Attackers are using AI to find and exploit weaknesses faster than ever, and defenders are using AI to fight back. Someone has to point those AI tools at the right problems, check their work, and make the call when it matters. That someone is a human who knows the fundamentals *and* knows how to work with AI.

That's who this course makes you: someone who can build in the **cloud**, control **identity** (who can do what), and use **AI** to move fast without becoming the security hole.

*Inspired by [The AI vs AI Battle for the Internet](https://open.spotify.com/episode/6u7ZO8Elg46mWjdu6jXzeU) from The AI Daily Brief.*

---

## The three pillars

Everything in this course serves one of three pillars. Every lesson is tagged with the pillar(s) it builds, so you always know *why* you're learning it.

| Pillar | What it means | Where you build it |
|---|---|---|
| ☁️ **Cloud** | Most of what you'll defend runs in someone else's data center. We use AWS. | Module 6, then everywhere |
| 🪪 **Identity** | Attackers don't break in, they log in. Who can do what is the new perimeter. | Module 7, then everywhere |
| 🤖 **AI** | AI is a fast, hard-working junior engineer. You learn to use it *and* to keep it in a box. | Module 1, then every module |

---

## The roadmap

There's no timetable. People learn at different speeds. Each module opens with a **"You're ready to move on when…"** checklist. When you can tick every box, move on.

### Foundations: what the pillars stand on
| # | Module | You'll be able to… |
|---|---|---|
| 0 | [Start Here](00-start-here/) | Use Git and GitHub, set up your portfolio, and know the rules of the road |
| 1 | [AI Foundations](01-ai-foundations/) 🤖 | Pick the right Claude model for the job and use AI without leaking secrets |
| 2 | [Linux](02-linux/) | Run and harden a Linux server from the command line |
| 3 | [Python](03-python/) 🤖 | Write a real CLI tool, `logslayer`, by hand and with AI |
| 4 | [Networking](04-networking/) | Explain how data gets from A to B, and troubleshoot when it doesn't |
| 5 | [Containers](05-containers/) 🪪 | Build small, secure container images on Chainguard |

### The pillars
| # | Module | You'll be able to… |
|---|---|---|
| 6 | [Cloud (AWS)](06-cloud-aws/) ☁️ | Turn an app architecture into AWS services, defined in OpenTofu |
| 7 | [Identity & Access](07-identity/) 🪪 | Read any IAM policy and say who can do what, and why |

### Applying the pillars
| # | Module | You'll be able to… |
|---|---|---|
| 8 | [Security Concepts](08-security-concepts/) ☁️🪪🤖 | Secure an app end to end, including the AI that helped build it |
| 9 | [Incident Response & Forensics](09-incident-response/) ☁️🪪🤖 | Detect, run, and write up an incident |

### Getting hired
| # | Module | You'll be able to… |
|---|---|---|
| 10 | [Capstone & Getting Hired](10-capstone-and-hired/) | Show a portfolio, tell your story, and pass the interview |

**Optional:** [Dig Deeper](dig-deeper/) topics (Kubernetes and more) and the [appendix](appendix/), including [three mock interviews](appendix/mock-interviews.md).

---

## How every lesson works

Every lesson follows the same rhythm:

1. **Why this matters**: a few sentences, usually a real-world consequence
2. **Do it**: hands on the keyboard, step by step
3. **Break it**: cause a failure on purpose and read the error
4. **With Claude**: do it again with AI
5. **Check yourself**: quick questions, answers hidden until you click
6. **Go deeper**: optional links, never required

You learn by doing. Reading about `chmod` won't get you hired. Typing it fifty times will.

---

## What you need

- **A laptop.** 8 GB of RAM is comfortable; 4 GB works with a lean setup.
- **Free accounts:** GitHub and AWS (you'll make the AWS one in Module 6, not before).
- **One paid item (recommended): Claude Pro, about $20/month.** Start it at Module 3 and most people finish the AI-heavy work in about two months. Can't pay? The [free AI path](appendix/free-ai-path.md) uses OpenCode with free models instead.

Everything else is free: Ubuntu, VirtualBox or UTM, Python, Docker Engine, Chainguard's free images, OpenTofu, GitHub Actions on public repos, and the AWS Free Tier. See [AWS cost safety](appendix/aws-cost-safety.md) before you touch AWS.

---

## Your portfolio

From Module 0 on, you build a **public GitHub repo of your own**. By the end it holds:

- A hardened Linux server and the script that hardens it
- `logslayer`, a Python CLI that parses logs and detects attacks
- A minimal, signed, scanned container image
- A notes app on AWS, defined entirely in **OpenTofu**
- An identity design for that app, with least-privilege roles
- A CI/CD pipeline that deploys with no stored AWS keys
- A Claude Code managed-settings policy that keeps AI in a box
- An incident postmortem from an attack you detected yourself

That's your proof. Most entry-level candidates can show one of these. You'll show all of them.

---

## Fast-moving facts

Prices, free tiers, and AI models change. Anything that might move has a **Last verified** date next to it. If you find one that's out of date, [open an issue](../../issues/new/choose).

## Disclosure

The author works at Chainguard. This course is an independent personal project and is not affiliated with, sponsored by, or endorsed by Chainguard. The course uses Chainguard's free container images because the author used and recommended them before joining the company, and they're free for anyone with no account needed.

## Contributing

Found something confusing? A broken link? Are you a hiring manager with real interview questions to share? See [CONTRIBUTING.md](CONTRIBUTING.md). Lesson authors: read [STYLE.md](STYLE.md) first.
