# Identity 101

**Pillars:** 🪪 Identity

## Why this matters

Most breaches today don't involve clever exploits. Attackers log in, with a stolen password, a leaked key, or a session cookie. Once they're in, what they can do depends entirely on **what that identity is allowed to do**. That's why "identity is the new perimeter": the wall around the network matters less than the rules about who can do what.

Every identity system, from Linux to AWS to the app you'll build next, answers two separate questions. Mix them up and you'll misread every access error you ever see.

## The two questions

| | **Authentication** (authn) | **Authorization** (authz) |
|---|---|---|
| Question | Who are you? | What are you allowed to do? |
| Proven by | A password, a key, MFA, a token | Permissions, policies, group membership |
| Fails with | "Invalid credentials," HTTP `401` | "Access denied," HTTP `403` |
| Linux | Logging in over SSH with your key | File permissions, `sudo` group |
| AWS | `aws login`, MFA, temporary credentials | IAM policies |

## Do it

1. **Linux, revisited.** In your VM:

   ```bash
   whoami
   id
   sudo -l
   ```

   `whoami` and `id` are the **authentication** answer: who the system thinks you are, with your user ID and groups. `sudo -l` is an **authorization** answer: what you're allowed to run as root. You learned both halves in [Module 2](../02-linux/07-users-and-groups.md) without the names.

2. **AWS, the same two questions.** Sign in, then ask who AWS thinks you are:

   ```bash
   aws login --remote --profile me
   aws sts get-caller-identity
   ```

   That call **always** succeeds for any valid credentials, because it only answers authentication. It needs no permissions. Now ask an authorization question, as Claude's role from [Module 6](../06-cloud-aws/12-claude-and-aws.md):

   ```bash
   cd ~/my-security-portfolio/notes-app/infra && tofu apply
   aws sts get-caller-identity --profile claude
   aws dynamodb scan --table-name notes-notes --profile claude
   ```

   ```
   An error occurred (AccessDeniedException) when calling the Scan operation:
   User: arn:aws:sts::123456789012:assumed-role/claude-readonly/claude-code is not authorized
   to perform: dynamodb:Scan on resource: ... because no identity-based policy allows the
   dynamodb:Scan action
   ```

   Authentication **passed**: AWS knows exactly who's asking. Authorization **failed**: that identity isn't allowed. Two different questions, two different answers.

3. **The same split in the notes app.** Your delete route from [Module 6](../06-cloud-aws/08-secrets.md) checks an admin token. Which question is that answering?

   <details><summary>Answer</summary>

   Both, in one step, which is a shortcut. Having the token proves you're "the admin" (authentication) and the code allows anyone with it to delete (authorization). Real apps separate them: log in first, then check what that user may do. That's how Module 8 hardens it.
   </details>

4. Start `identity/identity-notes.md` in your portfolio with the table above, and add one example of each from your own work in this course.

## Break it

Watch the status codes tell the two apart. Call your notes API's delete route three ways:

```bash
API=$(tofu output -raw api_url)
curl -s -o /dev/null -w "%{http_code}\n" -X DELETE "$API/notes/abc"
curl -s -o /dev/null -w "%{http_code}\n" -X DELETE "$API/notes/abc" -H "x-admin-token: wrong"
```

Both return `403`. Strictly, "no token at all" is an authentication failure and should be `401`; "a token that isn't allowed" is `403`. Many real apps blur them like this, and many security tools rely on telling them apart. Write in your notes which one each request really was, and how you'd fix the code. Then run your [end-of-session checklist](../06-cloud-aws/01-account-setup.md).

## With Claude

Ask Claude Code:

```text
Explain authentication vs. authorization using three examples from my own
course work: Linux, AWS, and the notes app API in notes-app/lambda/notes.py.
```

**Check the work:** are the examples actually from your files, or generic ones about websites and passwords? Does it correctly say `sts get-caller-identity` needs no permissions? (Check: it's true; AWS documents it.) Does it get `401` and `403` the right way round?

```bash
cd ~/my-security-portfolio
git add identity/identity-notes.md
git commit -m "Start identity notes"
git push
```

## Check yourself

1. A user's password is right, but they get "access denied" opening a file. Authentication or authorization?
   <details><summary>Answer</summary>

   Authorization. They proved who they are; they aren't allowed to do that.
   </details>

2. What's the difference between HTTP `401` and `403`?
   <details><summary>Answer</summary>

   `401`: we don't know who you are (log in). `403`: we know who you are, and you're not allowed.
   </details>

3. Why does `aws sts get-caller-identity` work for any valid credentials?
   <details><summary>Answer</summary>

   It only answers "who am I?" (authentication), so it needs no permissions. That's also why attackers with stolen keys call it first.
   </details>

## Go deeper

- [AWS: how IAM works](https://docs.aws.amazon.com/IAM/latest/UserGuide/intro-structure.html): principals, requests, authentication, and authorization, in AWS's words.
