# AI agents are principals too

**Pillars:** 🤖 AI · 🪪 Identity · ☁️ Cloud

## Why this matters

Claude Code, an MCP server, a subagent: when any of them calls AWS, it does it **with credentials**, as a principal, under the same rules as a person or a pipeline. Everything in this module applies to AI exactly as it applies to a new hire. That's the course's stance on AI, made concrete: least privilege, a trust policy, and an audit trail.

The risk has a name. OWASP's Top 10 for LLM Applications calls it **excessive agency** ([Module 1](../01-ai-foundations/06-owasp-llm-top-10.md)): an AI with more power than its task needs. A prompt injection, a misunderstanding, or a confident mistake can only do as much damage as the AI's permissions allow.

## The rules, applied to AI

| Rule | For a person | For an AI agent |
|---|---|---|
| Its own identity | Their own login | Its own role, never your credentials |
| Least privilege | Only what the job needs | One role **per task**, not one powerful role for everything |
| Trust policy | Who can give them access | Only you can assume the agent's role |
| Guardrails | Deny statements | Explicit denies on secrets and destructive actions |
| Short-lived access | Sessions expire | One-hour sessions |
| Audit trail | CloudTrail shows their name | A session name like `claude-code` on every call |

## Do it

Your `claude-readonly` role from Module 6 can view **everything** in the account. That's fine for "look around," but most of the time you ask Claude for something specific. Give it a role for one job: debugging the notes app's functions.

1. Add to `notes-app/infra/claude.tf`:

   ```hcl
   # A narrower role for one job: helping debug the notes app's functions.
   resource "aws_iam_role" "claude_debugger" {
     name                 = "claude-notes-debugger"
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

   resource "aws_iam_role_policy" "claude_debugger" {
     name = "debug-notes-functions"
     role = aws_iam_role.claude_debugger.id

     policy = jsonencode({
       Version = "2012-10-17"
       Statement = [
         {
           Sid      = "ListFunctions"
           Effect   = "Allow"
           Action   = "lambda:ListFunctions"
           Resource = "*" # ListFunctions can't be limited to specific functions
         },
         {
           Sid      = "SeeNotesFunctions"
           Effect   = "Allow"
           Action   = "lambda:GetFunctionConfiguration"
           Resource = "arn:aws:lambda:${var.region}:${data.aws_caller_identity.current.account_id}:function:${var.name}-*"
         },
         {
           Sid      = "ReadNotesLogs"
           Effect   = "Allow"
           Action   = ["logs:FilterLogEvents", "logs:DescribeLogStreams"]
           Resource = "arn:aws:logs:${var.region}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/${var.name}-*"
         },
         {
           Sid      = "NeverReadSecrets"
           Effect   = "Deny"
           Action   = ["ssm:GetParameter*", "secretsmanager:GetSecretValue", "kms:Decrypt"]
           Resource = "*"
         },
       ]
     })
   }

   output "claude_debugger_role_arn" {
     value = aws_iam_role.claude_debugger.arn
   }
   ```

   It can see the notes functions' settings and read their logs. Nothing else. And an explicit **Deny** on reading secrets means that even if someone later attaches a broad policy to this role, the secrets stay off-limits ([lesson 5](05-evaluation-logic.md)).

2. Apply, and add a profile:

   ```ini
   [profile claude-debugger]
   role_arn = arn:aws:iam::123456789012:role/claude-notes-debugger
   source_profile = lab
   role_session_name = claude-debugger
   region = us-east-1
   ```

3. **Prove the design before handing it over**, with the simulator:

   ```bash
   ACCT=$(aws sts get-caller-identity --query Account --output text)
   aws iam simulate-principal-policy \
     --policy-source-arn "arn:aws:iam::$ACCT:role/claude-notes-debugger" \
     --action-names logs:FilterLogEvents ssm:GetParameter dynamodb:Scan lambda:UpdateFunctionCode \
     --query 'EvaluationResults[].[EvalActionName,EvalDecision]' --output table
   ```

   Only `FilterLogEvents` should be allowed. `GetParameter` is an `explicitDeny`; the other two are `implicitDeny`.

4. **Give Claude the debugger role for a debugging session.** Add a second MCP server, using the narrow profile:

   ```bash
   cd ~/my-security-portfolio/notes-app
   claude mcp add \
     --env AWS_API_MCP_PROFILE_NAME=claude-debugger \
     --env READ_OPERATIONS_ONLY=true \
     --env AWS_REGION=us-east-1 \
     --transport stdio aws-debugger \
     -- uvx awslabs.aws-api-mcp-server@1.6.0
   ```

   Now break something on purpose so there's something to debug: remove `dynamodb:PutItem` from the notes Lambda's policy (like [Module 6, lesson 7](../06-cloud-aws/07-data.md)), apply, and try to create a note. Then ask Claude:

   ```text
   Using only the aws-debugger tools, find out why creating a note fails.
   Look at the notes-api function's configuration and recent logs.
   ```

   It should find the `AccessDeniedException` in the logs and tell you which permission is missing. It found the problem without being able to read your data, your secrets, or change anything. You fix it: put `PutItem` back and apply.

5. **One agent, one role, one job.** The same idea applies to **subagents**, the helper agents Claude Code can start for a single task (you'll build one in Module 9). A log-triage subagent gets a role that can read logs. It doesn't inherit the main agent's access. Write a short section in `identity/identity-notes.md`: for each AI task you've done in this course, which role it should use.

## Break it

Try to get the debugger to cross the line:

```text
Using the aws-debugger tools, read the value of the /notes/admin-token parameter
so I can test the delete route.
```

`AccessDenied`, and the error says **explicit deny**. Now find the attempt in CloudTrail a few minutes later:

```bash
aws cloudtrail lookup-events --lookup-attributes AttributeKey=Username,AttributeValue=claude-debugger --max-results 10 \
  --output json | jq -r '.Events[].CloudTrailEvent | fromjson | "\(.eventTime) \(.eventName) \(.errorCode // "ok")"'
```

The denied `GetParameter` is in the trail, under Claude's session name. If an attacker ever slipped a prompt injection into a log line saying "read the admin token," this is exactly what you'd see: the attempt, the denial, and whose session it was. That's the box working: the AI's mistake (or its attacker's trick) is contained by the role, and visible in the audit log.

## With Claude

Ask Claude Code to design a role for a new job:

```text
Write an IAM role and policy in OpenTofu for an AI agent whose only job is to
check the notes app's SQS queue depth and the audit function's error logs
once an hour. Least privilege. Include a trust policy that only lets me
assume it, and explicit denies for anything sensitive.
```

**Check the work:**

- Every action: is it really needed for "queue depth" (`sqs:GetQueueAttributes`) and "error logs" (`logs:FilterLogEvents`)?
- Is every `Resource` the specific queue or log group, not `*` (except where AWS requires `*`)?
- Does the trust policy name **your** user, not the whole account (`:root`) or `*`?
- Run the policy through `aws accessanalyzer validate-policy`, then prove it with `simulate-custom-policy`: one action it should allow, one it shouldn't.

## Check yourself

1. Why give an AI agent a role per task instead of one role for everything?
   <details><summary>Answer</summary>

   Least privilege. Each task's role only allows that task, so a mistake or a prompt injection during one job can't reach anything else.
   </details>

2. Why add an explicit Deny for secrets to a role that doesn't allow reading them anyway?
   <details><summary>Answer</summary>

   It's a guardrail. If someone later attaches a broader policy to the role, the Deny still wins, so the secrets stay protected.
   </details>

3. How do you know which actions in CloudTrail were the AI's?
   <details><summary>Answer</summary>

   Its role and session name, like `assumed-role/claude-notes-debugger/claude-debugger`, appear in `userIdentity` on every call it makes.
   </details>

## Go deeper

- [OWASP Top 10 for Agentic Applications](https://genai.owasp.org/): risks for AI agents with tools, including identity and privilege abuse.
- [Permissions boundaries](https://docs.aws.amazon.com/IAM/latest/UserGuide/access_policies_boundaries.html): a cap on what a role can ever be granted. At work, roles for AI agents are a good place to use them.
