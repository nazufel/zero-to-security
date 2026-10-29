# Secrets management

**Pillars:** 🪪 Identity · ☁️ Cloud · 🤖 AI

## Why this matters

Secrets leak through people, not just code: a token pasted in a chat, an `.env` file copied to a new laptop, a key in a screenshot, a password in an AI prompt. In [Module 6](../06-cloud-aws/08-secrets.md), you moved the notes app's one secret into Parameter Store. In lesson 3, you removed it entirely, by using identity instead.

That's the order of preference for any secret: **don't have it** (use identity), and if you must, **store it in one place**, **give access by role**, **rotate it**, and **scan for it everywhere else**. This lesson finishes the job and sets up the scanning.

## Do it

1. **Inventory every secret you have.** In `security/secrets.md`, list every credential that exists for your work in this course, where it lives, and what would happen if it leaked:

   | Secret | Where it lives | If it leaked | Can it be replaced by identity? |
   |---|---|---|---|
   | AWS admin password | Password manager | Account takeover, if MFA also failed | No (it **is** an identity) |
   | `aws login` session | `~/.aws/login/cache` in the VM | Admin access for up to 12 hours | Already temporary |
   | GitHub login | `~/.config/gh` in the VM | Push to my repos | Narrower token, or sign out when idle |
   | Admin token | Deleted in lesson 3 | — | Yes: done |
   | SSH key to EC2 | `~/.ssh/aws_lab` | Shell on the lab server | Yes: lesson 7 |

   Add anything else you have, like other API keys. The goal is a short list where every row has a reason.

2. **Scan your whole history.** You ran [gitleaks](https://github.com/gitleaks/gitleaks) once in Module 6. Now scan every commit in your portfolio:

   ```bash
   cd ~/my-security-portfolio
   sudo docker run --rm -v "$PWD:/repo:ro" ghcr.io/gitleaks/gitleaks:latest git /repo --verbose
   ```

   Expect `no leaks found`. If it finds one, follow [the rule from Module 0](../00-start-here/03-git-and-github.md): **the secret is compromised**. Revoke and replace it first. Cleaning history comes second.

3. **Keep secrets away from Claude.** Claude Code can read any file it can reach. Add deny rules for the usual hiding places to `~/.claude/settings.json`, next to the ones from Modules 2 and 6:

   ```json
   "Read(./.env)",
   "Read(./.env.*)",
   "Read(~/.ssh/**)",
   "Read(~/.config/gh/**)",
   "Read(**/*.tfstate)"
   ```

   State files are on the list for the reason you saw in [Module 6, lesson 3](../06-cloud-aws/03-opentofu-basics.md). In lesson 12, these rules move into a managed policy that Claude can't edit.

## Break it

Commit a secret, and catch it **before** it's pushed. Make a fake one that looks real enough for the scanner:

```bash
cd ~/my-security-portfolio
echo 'PAYMENT_API_KEY = "8f3a9c1e7b2d4f6a0c5e9b1d3f7a2c4e"' > leak-test.env
git add leak-test.env
git commit -m "test: fake secret"
sudo docker run --rm -v "$PWD:/repo:ro" ghcr.io/gitleaks/gitleaks:latest git /repo --log-opts="-1"
```

Roughly:

```
Finding:     PAYMENT_API_KEY = "8f3a9c1e7b2d4f6a0c5e9b1d3f7a2c4e"
RuleID:      generic-api-key
File:        leak-test.env
...
leaks found: 1
```

Caught, and it never left your laptop. Undo it the way you learned in Module 0:

```bash
git reset --hard HEAD~1
```

`--log-opts="-1"` scanned only the last commit, which is how you'd check before every push. In lesson 13, the pipeline runs this scan on every push automatically, so a secret that slips past you still gets caught, though by then it has reached GitHub and must be treated as leaked.

## With Claude

Ask Claude Code:

```text
Scan this repository for anything that looks like a secret, and also for
places where a secret could easily be added by mistake in future, like code
that reads from a .env file or a config file that isn't gitignored. Don't
read any file matching my deny rules.
```

**Check the work:** compare with gitleaks. Did Claude respect your deny rules, or try to read `.env` or `~/.ssh` anyway? (If it tried, the rule blocked it; check the transcript.) Its "where a secret could be added" list is the useful part: a scanner finds secrets that exist; a reviewer spots places they're likely to appear. Add any real ones to `secrets.md`.

```bash
git add security/secrets.md
git commit -m "Add secrets inventory"
git push
```

## Check yourself

1. What's the best way to protect a secret?
   <details><summary>Answer</summary>

   Not have one: replace it with identity, like signed requests instead of a shared token. If you must have one, keep it in a secret store, grant access by role, and rotate it.
   </details>

2. A scan finds a real key in a commit from last year. What's the first thing you do?
   <details><summary>Answer</summary>

   Revoke and replace the key. Assume it's been copied. Cleaning it out of Git history comes after.
   </details>

3. Why deny Claude Code from reading `*.tfstate`?
   <details><summary>Answer</summary>

   State files can contain secrets in plain text and a full map of your infrastructure. An AI agent doesn't need either to help with code.
   </details>

## Go deeper

- [OWASP Secrets Management Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Secrets_Management_Cheat_Sheet.html)
- [GitHub secret scanning](https://docs.github.com/en/code-security/secret-scanning/introduction/about-secret-scanning): free on public repositories, and worth turning on for your portfolio.
