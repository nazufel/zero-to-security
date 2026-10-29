# Least privilege

**Pillars:** 🪪 Identity · ☁️ Cloud

## Why this matters

Permissions only grow. Someone adds an action "just in case," a feature gets removed but its permission stays, and a managed policy grants more than anyone read. Two years later, a role that writes notes can also create log groups anywhere in the account. Nobody decided that. It just accumulated.

Least privilege isn't a setting you turn on once. It's a habit of checking what each identity **actually uses** and removing the rest. In this lesson you'll do that to the notes app.

## Do it

1. **Ask AWS what the notes function actually uses.** IAM tracks when each service was last used by a role, free:

   ```bash
   cd ~/my-security-portfolio/notes-app/infra && tofu apply
   ACCT=$(aws sts get-caller-identity --query Account --output text)
   JOB=$(aws iam generate-service-last-accessed-details --arn "arn:aws:iam::$ACCT:role/notes-lambda" --query JobId --output text)
   sleep 5
   aws iam get-service-last-accessed-details --job-id "$JOB" \
     --query 'ServicesLastAccessed[?TotalAuthenticatedEntities > `0`].[ServiceNamespace,LastAuthenticated]' --output table
   ```

   (Use the app first, if it's been idle: add and list a few notes.) It shows which services the role has really called. Anything it's **allowed** to use but **never** has is a candidate to remove.

2. **Read every permission against the code.** Open `lambda/notes.py` next to the role's policy in `lambda.tf`. For each action, find the line of code that needs it:

   | Action | Used by | Keep? |
   |---|---|---|
   | `dynamodb:PutItem` | `create_note` | Yes |
   | `dynamodb:DeleteItem` | `delete_note` | Yes |
   | `dynamodb:Scan` | `list_notes` | Yes |
   | `dynamodb:GetItem` | ? | |
   | `ssm:GetParameter` | `admin_token` | Yes, for now (lesson 3 changes this) |
   | `sqs:SendMessage` | `create_note` | Yes |

   `GetItem` isn't used by anything (unless you added a `GET /notes/{id}` route with Claude in Module 6; if so, keep it). Remove what isn't used.

3. **Replace the broad managed policy.** Both functions attach `AWSLambdaBasicExecutionRole`. Look at what it allows:

   ```bash
   aws iam get-policy-version --policy-arn arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole \
     --version-id v1 --query PolicyVersion.Document
   ```

   `logs:CreateLogGroup`, `CreateLogStream`, and `PutLogEvents` on `*`: every log group in the account. Your functions only ever write to their own log group, which OpenTofu already creates. In `lambda.tf`, delete the `aws_iam_role_policy_attachment.notes_logs` resource and add this statement to the notes role's policy instead:

   ```hcl
         {
           Effect   = "Allow"
           Action   = ["logs:CreateLogStream", "logs:PutLogEvents"]
           Resource = "${aws_cloudwatch_log_group.notes.arn}:*"
         },
   ```

   Do the same for the audit function in `sqs.tf`, with `aws_cloudwatch_log_group.audit`.

4. Apply, then **prove nothing broke**: create a note, list notes, and check both functions' logs still arrive:

   ```bash
   tofu apply
   API=$(tofu output -raw api_url)
   curl -s -X POST "$API/notes" -d '{"text": "least privilege test"}'
   aws logs tail /aws/lambda/notes-api --since 5m | tail -3
   aws logs tail /aws/lambda/notes-audit --since 5m | tail -3
   ```

5. Commit:

   ```bash
   git add lambda.tf sqs.tf
   git commit -m "Tighten Lambda roles to what the code uses"
   git push
   ```

## Break it

Take away too much, and notice how quietly it fails. Remove `logs:PutLogEvents` from the notes role's logging statement, apply, and use the app:

```bash
curl -s -X POST "$API/notes" -d '{"text": "can you see me?"}'
aws logs tail /aws/lambda/notes-api --since 2m
```

The note is created; the app works. But the newest log lines are missing. The function can't write its logs, and nothing tells you, because the thing that would tell you is the log.

That's the trap of least privilege done carelessly: you don't always get a loud error. Sometimes you just go **blind**, and you find out during an incident, when you need the logs most. That's why step 4 checks the logs, not just the app. Put `PutLogEvents` back and apply.

## With Claude

Ask Claude Code:

```text
Compare the IAM policies in notes-app/infra/*.tf with the code in
notes-app/lambda/. List every permission that no line of code uses, and
every call the code makes that no permission allows. Don't change files.
```

**Check the work:** for each "unused permission," search the code yourself (`grep -n "get_item\|put_item" ../lambda/*.py`). For each "missing permission," would it really fail? Some calls (like `boto3.client("sqs")`) don't call AWS at all; only the method calls do. Claude is good at this comparison, and also good at being confidently wrong about which method needs which action. Check the [service authorization reference](https://docs.aws.amazon.com/service-authorization/latest/reference/reference_policies_actions-resources-contextkeys.html) for anything you're unsure of.

## Check yourself

1. How do you find permissions a role has but doesn't use?
   <details><summary>Answer</summary>

   IAM's last-accessed data (`generate-service-last-accessed-details`) for services, then comparing the policy line by line with the code that runs as the role.
   </details>

2. What's wrong with `AWSLambdaBasicExecutionRole` for a single function?
   <details><summary>Answer</summary>

   It allows creating and writing to every log group in the account. A function only needs to write to its own.
   </details>

3. You removed a permission and the app still works. Are you done?
   <details><summary>Answer</summary>

   Not yet. Check that logging, alerts, and background jobs still work too. Some missing permissions fail silently.
   </details>

## Go deeper

- [IAM: refine permissions using last accessed information](https://docs.aws.amazon.com/IAM/latest/UserGuide/access_policies_last-accessed.html)
