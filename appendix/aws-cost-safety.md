# AWS cost safety

**Read this before you create an AWS account.**

## Why this matters

People new to the cloud get surprise bills. Not because AWS is a scam, but because it's built to run forever until you tell it to stop. A forgotten server or one expensive network component can quietly run up charges. A few habits make that close to impossible.

## How the free plan works

> **Last verified:** 2026-10-27 ([AWS Free Tier](https://aws.amazon.com/free/), [FAQs](https://aws.amazon.com/free/faqs/))

- New accounts choose a **Free plan** or a **Paid plan** at sign-up. **Choose the Free plan.**
- On the Free plan, you aren't charged unless you upgrade to the Paid plan.
- You get $100 in credits at sign-up, and can earn up to $100 more by trying certain services.
- The Free plan ends **6 months after sign-up, or when your credits run out**, whichever comes first.
- About 30 services stay **always free** within monthly limits, on either plan.
- **Joining an AWS Organization or setting up Control Tower ends your free credits immediately.** This course never asks you to do either.

**Timing tip:** don't create your account until Module 6. Your six months start the day you sign up.

## Set this up on day one

1. **MFA on the root user.** The root user can do anything, including close your account. Protect it first, then stop using it.
2. **A budget alert.** In Billing → Budgets, create a monthly cost budget of **$1** with an email alert. If anything starts costing money, you'll know right away.
3. **A non-root admin user** in an admin group, with MFA. Use it for daily work. *(You'll learn why in Module 7.)*
4. **One region.** Pick the one closest to you and use it for everything, so nothing is hiding in a region you forgot about.

## The end-of-session habit

Every time you finish working:

```bash
tofu destroy
```

Because everything in this course is defined in OpenTofu, one command removes it all. Then glance at the **Billing** dashboard. That's it.

> **Why OpenTofu helps here:** your code *is* your inventory. If it's not in the code, you didn't create it, and if you destroy the code's resources, nothing is left running.

## What costs money (and what we avoid)

The course is designed to avoid these, but you'll see them at work and in other tutorials:

| Thing | Why it's a risk |
|---|---|
| NAT Gateways | Charged by the hour plus data, even when idle |
| Servers left running | EC2 instances bill around the clock |
| Public IPv4 addresses | AWS charges for them by the hour |
| Managed databases (RDS) | Bill by the hour, even with no traffic |
| Kubernetes (EKS) | The control plane bills by the hour. That's why Kubernetes in this course runs locally. |
| Big data transfers out | Downloading lots of data from AWS costs money |

## Never do this

- **Never commit AWS access keys** to Git, even to a private repo. Bots find them in minutes, and stolen keys are used to run expensive crypto-mining servers on your account.
- **Never commit OpenTofu state files.** They can contain secrets. The course's `.gitignore` blocks them.
- **Never share your root user login** with anyone, or with any AI tool.

## If you get a surprise bill

1. Don't panic. Run `tofu destroy`, then check every region in the console for anything still running.
2. If you think your keys leaked, deactivate them immediately (Module 9 walks through this).
3. Contact AWS Support from the Billing console. They often help people who made honest mistakes, especially if you act fast.
