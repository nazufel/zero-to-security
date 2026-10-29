# Claude and AWS

**Pillars:** 🤖 AI · 🪪 Identity · ☁️ Cloud

## Why this matters

Hooking an AI agent up to your cloud account is very useful: "what's running, what does it cost, why is this failing?" answered in seconds. It's also the clearest test yet of the course's rule: **don't put AI into your world; give it parts of your world, explicitly.** An agent using **your** admin credentials can do anything you can, including delete everything, and if it's prompt-injected by something it reads, so can whoever wrote that text.

So Claude gets **its own role**: a separate identity that can only look, that only you can hand it, and that shows up under its own name in CloudTrail.

## Do it

1. **Create Claude's role.** In `notes-app/infra`, create `claude.tf`:

   ```hcl
   # A role for Claude Code to use through the AWS MCP server.
   # Only you (the admin user) can assume it, and it can only view, never change.
   resource "aws_iam_role" "claude" {
     name                 = "claude-readonly"
     max_session_duration = 3600

     assume_role_policy = jsonencode({
       Version = "2012-10-17"
       Statement = [{
         Effect    = "Allow"
         Principal = { AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/admin" }
         Action    = "sts:AssumeRole"
       }]
     })
   }

   resource "aws_iam_role_policy_attachment" "claude_view_only" {
     role       = aws_iam_role.claude.name
     policy_arn = "arn:aws:iam::aws:policy/job-function/ViewOnlyAccess"
   }

   output "claude_role_arn" {
     value = aws_iam_role.claude.arn
   }
   ```

   - The **trust policy** says only your `admin` user can assume this role.
   - **ViewOnlyAccess** is an AWS-managed policy that can list and describe resources, but not read your data (not the notes in DynamoDB, not files in S3, not secret values) and not change anything. That's narrower than `ReadOnlyAccess`, which **can** read data. Pick the narrowest one that does the job.
   - Sessions last at most an hour.

   ```bash
   tofu apply
   ```

2. **Give Claude a profile that uses the role.** Add to `~/.aws/config`, with your account ID:

   ```ini
   [profile claude]
   role_arn = arn:aws:iam::123456789012:role/claude-readonly
   source_profile = lab
   role_session_name = claude-code
   region = us-east-1
   ```

   Test it yourself first:

   ```bash
   aws sts get-caller-identity --profile claude
   ```

   ```json
   {
       "Arn": "arn:aws:sts::123456789012:assumed-role/claude-readonly/claude-code"
   }
   ```

   `role_session_name = claude-code` is a label that appears in every CloudTrail event this profile makes. Now you'll always know which calls were Claude's.

3. **Connect Claude Code to AWS through MCP.** **MCP** (Model Context Protocol) is the standard way to give an AI agent tools ([Module 1](../01-ai-foundations/07-claude-ecosystem.md)). AWS publishes an MCP server that lets an agent run AWS API calls. Add it, pinned to a version, using the `claude` profile, in read-only mode:

   ```bash
   cd ~/my-security-portfolio/notes-app
   claude mcp add \
     --env AWS_API_MCP_PROFILE_NAME=claude \
     --env READ_OPERATIONS_ONLY=true \
     --env AWS_REGION=us-east-1 \
     --transport stdio aws \
     -- uvx awslabs.aws-api-mcp-server@1.6.0
   claude mcp list
   ```

   > **Last verified:** 2026-10-29 ([AWS API MCP server](https://github.com/awslabs/mcp/tree/main/src/aws-api-mcp-server)). AWS now also offers a managed **AWS MCP Server**, and says it supersedes this one. Whichever you use, the security setup in this lesson is the same: its own role, the narrowest policy, read-only, pinned. If this server is retired, follow AWS's docs for the managed one and keep the `claude` profile.

   Two layers of "read only": `READ_OPERATIONS_ONLY` in the server, and **ViewOnlyAccess** in IAM. The MCP server's own docs say IAM is the real control; the setting is a second layer.

4. **Use it.** Start `claude` in `notes-app`, and ask:

   ```text
   Using the AWS tools, list what's deployed in my account for the notes app:
   Lambda functions, the DynamoDB table, the SQS queue, and the EC2 instance.
   For each, tell me one security setting you can see.
   ```

   Approve each tool call after reading it. You'll see answers come back about your functions' runtimes and roles, the instance's IMDSv2 setting, the queue's encryption.

## Break it

**Part 1: the role holds.** Ask Claude to change something:

```text
Using the AWS tools, create an S3 bucket called claude-test-<some random digits>.
```

It's refused: the MCP server is in read-only mode. Even if it weren't, the role has no permission to create anything. Now ask it to read your data:

```text
Using the AWS tools, show me the items in the notes-notes DynamoDB table.
```

`AccessDenied`. ViewOnlyAccess can see the table exists, not what's in it. Find the evidence in CloudTrail a few minutes later:

```bash
aws cloudtrail lookup-events --lookup-attributes AttributeKey=Username,AttributeValue=claude-code --max-results 10 \
  --query 'Events[].[EventTime,EventName]' --output table
```

Every call Claude made, under its own name.

**Part 2: the box has a hole.** MCP isn't the only way Claude can reach AWS. Claude Code can run shell commands, and your VM is signed in as **you**. Ask it:

```text
Run `aws sts get-caller-identity` in the shell and tell me who it says I am.
```

If you approve it, the answer is `user/admin`, your full admin session. Claude could run any `aws` or `tofu` command as you, and the read-only role means nothing. (In Manual mode it has to ask first, but one careless "yes" is enough.)

Close the hole with deny rules, like the `sudo` rule from [Module 2](../02-linux/11-claude-code-in-the-box.md). Edit `~/.claude/settings.json`:

```json
{
  "permissions": {
    "deny": [
      "Bash(sudo *)",
      "Bash(aws *)",
      "Bash(tofu *)",
      "Read(~/.aws/**)"
    ]
  }
}
```

Restart `claude` and ask again. Blocked. Claude reaches AWS **only** through the MCP server, as `claude-readonly`. You run `aws` and `tofu` yourself.

It's still a seatbelt, not a vault. A determined workaround might still exist, which is why the other layers matter: sign out with `aws logout --profile me` when you're not working, keep the VM as the box, and in Module 8, hooks and a managed policy make these rules harder to get around.

## With Claude

Ask Claude Code, with the MCP tools available:

```text
Review my AWS account for security problems you can see with your tools.
Prioritize the top five. For each, tell me what you saw and how you'd fix it.
```

**Check the work:**

- For each finding, look at the resource yourself, in the console or with `aws` (as you, not Claude). Is it real?
- Does any finding depend on data Claude **can't** see with ViewOnlyAccess? If it claims to know what's in a bucket or table, it's guessing.
- Did it recommend giving its own role more permissions "so it can check more"? That's the AI asking for excessive agency. Decline, and log it in your [AI check log](../01-ai-foundations/01-what-ai-is.md).

Commit your work, then run your [end-of-session checklist](01-account-setup.md):

```bash
git add claude.tf
git commit -m "Give Claude its own read-only AWS role"
git push
```

## Check yourself

1. Why does Claude get its own role instead of using your credentials?
   <details><summary>Answer</summary>

   So it can only do what its job needs (view, not change or read data), so only you can hand it access, and so its actions show up under its own name in CloudTrail.
   </details>

2. What's the difference between ViewOnlyAccess and ReadOnlyAccess?
   <details><summary>Answer</summary>

   ViewOnlyAccess lists and describes resources. ReadOnlyAccess can also read the data inside them, like S3 objects and DynamoDB items.
   </details>

3. Claude's MCP role is read-only. How could it still change your AWS account?
   <details><summary>Answer</summary>

   Through the shell, using your own signed-in session with `aws` or `tofu`. Deny those commands and reading `~/.aws`, and sign out when you're not working.
   </details>

## Go deeper

- [OWASP Top 10 for LLM Applications: Excessive Agency](https://genai.owasp.org/llmrisk/llm062025-excessive-agency/): the risk this lesson defends against.
- [AWS managed policies for job functions](https://docs.aws.amazon.com/IAM/latest/UserGuide/access_policies_job-functions.html): ViewOnlyAccess, ReadOnlyAccess, and the rest.
