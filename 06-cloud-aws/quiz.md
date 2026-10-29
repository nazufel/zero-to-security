# Module 6 quiz

Answer each question out loud or on paper *before* you open the answer.

1. Name the four things you set up in the first hour of a new AWS account.
   <details><summary>Answer</summary>

   MFA on root, a $1 budget alert, a non-root admin user (in an admin group, with MFA) for daily work, and one chosen region. Plus: no access keys.
   </details>

2. Map each part of an app to an AWS service: front end, back end, data store, secret store, blob store, message broker.
   <details><summary>Answer</summary>

   S3 + CloudFront, API Gateway + Lambda, DynamoDB, SSM Parameter Store, S3, SQS.
   </details>

3. Your EC2 instance is hacked through an outdated package. Your Lambda function is hacked through an outdated package in its zip. Whose responsibility was each patch?
   <details><summary>Answer</summary>

   Both yours. On EC2 you own the OS and everything on it. On Lambda, AWS patches the runtime, but your code and the packages you ship are yours.
   </details>

4. A plan says `-/+ resource "aws_dynamodb_table" "notes"`. What do you do?
   <details><summary>Answer</summary>

   Stop. `-/+` means destroy and recreate, which for a database means losing its data. Find out what change caused it before you apply.
   </details>

5. Why must `terraform.tfstate` never be committed, and where does it go at work?
   <details><summary>Answer</summary>

   It can hold secrets in plain text and maps your whole infrastructure. At work it lives in an encrypted, access-controlled remote backend, never in Git.
   </details>

6. A bucket's Block Public Access is on, and someone adds a policy with `"Principal": "*"`. What happens?
   <details><summary>Answer</summary>

   AWS refuses the policy. Block Public Access overrides public policies, which is exactly why it should stay on.
   </details>

7. Where should a Lambda function get a database password: hard-coded, an environment variable, or Parameter Store? Why?
   <details><summary>Answer</summary>

   Parameter Store (as a SecureString), read at runtime with permission for that one parameter. Hard-coded secrets end up in Git; environment variables are visible in plain text to anyone who can view the function, and in your IaC.
   </details>

8. Security group or NACL: which is stateful, and what breaks if you forget the difference?
   <details><summary>Answer</summary>

   Security groups are stateful. NACLs aren't, so they need a rule for return traffic on the ephemeral ports (1024–65535). Forget it and outgoing connections, like `apt update`, hang.
   </details>

9. CloudTrail shows an identity calling `GetCallerIdentity`, then getting `AccessDenied` on `ListUsers`, `GetSecretValue`, and `CreateUser` within a minute, from an unknown IP. What do you suspect?
   <details><summary>Answer</summary>

   Stolen credentials being used to discover what they can do. Treat it as a likely incident (Module 9).
   </details>

10. How did you give Claude access to AWS, and what stops it from changing anything?
    <details><summary>Answer</summary>

    Its own role (`claude-readonly`) with ViewOnlyAccess, assumable only by you, used through a pinned MCP server in read-only mode. Plus Claude Code deny rules for `aws`, `tofu`, and `~/.aws`, so it can't use your own session from the shell. Its calls show up in CloudTrail as `claude-code`.
    </details>

## Challenge

Without looking at the lessons: destroy everything, then bring the notes app back up from your repo alone, on a clean clone. Can you do it with only what's in your README?

```bash
cd /tmp && git clone https://github.com/yourname/my-security-portfolio
cd my-security-portfolio/notes-app/infra
```

If you get stuck, the missing step goes in the README. That's how documentation gets good. Destroy it when you're done.
