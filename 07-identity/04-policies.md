# Policies

**Pillars:** 🪪 Identity · ☁️ Cloud

## Why this matters

Every permission in AWS is a JSON **policy**. "Broken Access Control" is number 1 on the [OWASP Top 10](https://owasp.org/Top10/2025/), and in the cloud, it almost always comes down to a policy that allows more than someone realized. If you can read any policy and say exactly who can do what, to which resource, you can do one of the most in-demand jobs in cloud security.

## Anatomy of a policy

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "ReadNotes",
      "Effect": "Allow",
      "Action": ["dynamodb:GetItem", "dynamodb:Scan"],
      "Resource": "arn:aws:dynamodb:us-east-1:123456789012:table/notes-notes",
      "Condition": {
        "IpAddress": { "aws:SourceIp": "198.51.100.0/24" }
      }
    }
  ]
}
```

| Part | Means |
|---|---|
| `Version` | The policy language version. Always `2012-10-17`. |
| `Statement` | A list of rules |
| `Sid` | An optional label, for humans |
| `Effect` | `Allow` or `Deny` |
| `Action` | Which API calls, as `service:Action`. Wildcards allowed. |
| `Resource` | Which things, by **ARN** (Amazon Resource Name). Wildcards allowed. |
| `Condition` | Optional: only when these are true |

Read every statement as one sentence: "**Allow** `GetItem` and `Scan` **on** the notes table, **only when** the request comes from `198.51.100.0/24`."

## Where policies go

| Kind | Attached to | Answers | You've used it |
|---|---|---|---|
| **Identity-based** | A user, group, or role | What can **this identity** do? | The notes Lambda's role policy, `team.tf` |
| **Resource-based** | A resource, like a bucket or function | Who can do what **to this resource**? Has a `Principal`. | The site bucket policy, `aws_lambda_permission` |
| **Trust policy** | A role | Who can **become** this role? | Every `assume_role_policy` |
| **Permissions boundary** | A user or role | The **most** this identity can ever be allowed, whatever its other policies say | Not yet (lesson 8) |
| **SCP** (service control policy) | An account, via AWS Organizations | The most **anyone** in the account can do | At work. Not on the Free plan: [Organizations ends your credits](../appendix/aws-cost-safety.md). |

## Do it

1. **Read three real policies from your own account**, and write each as sentences in `identity/policy-reading.md`:

   ```bash
   aws iam get-role-policy --role-name notes-lambda --policy-name notes-app-access --query PolicyDocument
   aws s3api get-bucket-policy --bucket "$(aws s3 ls | awk '/notes-site-/ {print $3}')" --query Policy --output text | jq .
   aws iam get-role --role-name notes-audit --query Role.AssumeRolePolicyDocument
   ```

   (If the site bucket isn't deployed, read it from `frontend.tf` instead.) Identity-based, resource-based, and trust.

2. **Validate a policy before you use it.** IAM Access Analyzer checks policies for errors and risky patterns, free. Save this draft as `draft.json`:

   ```json
   {
     "Version": "2012-10-17",
     "Statement": [
       {
         "Effect": "Allow",
         "Action": "dynamodb:Scan",
         "Resource": "arn:aws:dynamodb:us-east-1:123456789012:table/notes"
       },
       {
         "Effect": "Allow",
         "Action": "iam:PassRole",
         "Resource": "*"
       }
     ]
   }
   ```

   ```bash
   aws accessanalyzer validate-policy --policy-type IDENTITY_POLICY --policy-document file://draft.json \
     --query 'findings[].[findingType,issueCode,findingDetails]' --output table
   ```

   It flags `iam:PassRole` on `*` as a **security warning**. `PassRole` lets an identity hand any role to a service, like giving a Lambda function the admin role. It's one of the classic ways to escalate privileges.

   It does **not** flag the first statement. But look closely at its `Resource`: `table/notes`. The real table is `table/notes-notes`. That statement grants nothing, and nothing warns you. That's why you test policies (next lesson), not just validate them.

## Break it

Write the most common bad policy in the world, and see how far it reaches. Save as `wide.json`:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    { "Effect": "Allow", "Action": "s3:*", "Resource": "*" }
  ]
}
```

Write down, before you look anything up, everything this allows. Then run it through Access Analyzer. Then check what `s3:*` really includes:

```bash
aws accessanalyzer validate-policy --policy-type IDENTITY_POLICY --policy-document file://wide.json
```

<details><summary>What it allows</summary>

Every S3 action, on every bucket in the account: reading and deleting every object, **deleting buckets**, **changing bucket policies** (including making them public), and turning off versioning, which destroys the backups from [Module 6](../06-cloud-aws/04-storage.md). Someone usually wrote it to let an app "read some files." The fix is the specific actions on the specific bucket ARN.
</details>

Delete `wide.json` and `draft.json` when you're done.

## With Claude

Ask Claude Code:

```text
Write an identity-based IAM policy that lets the lab server (lesson 6 will
give it a role) list the notes files bucket and download objects from it.
Nothing else. Explain each statement in one sentence.
```

**Check the work:**

- `s3:ListBucket` belongs on the **bucket** ARN (`arn:aws:s3:::name`), and `s3:GetObject` on the **objects** (`arn:aws:s3:::name/*`). Mixing them up is the most common S3 policy bug, and the policy silently grants nothing. Did Claude get them on the right ARNs?
- Did it use `s3:Get*` or `s3:*` instead of the exact actions?
- Run it through `validate-policy`. Any warnings?

Save it; you'll use it in lesson 6.

```bash
git add identity/policy-reading.md
git commit -m "Add policy reading notes"
git push
```

## Check yourself

1. Read this statement as a sentence: `{"Effect": "Allow", "Action": "logs:FilterLogEvents", "Resource": "arn:aws:logs:us-east-1:123456789012:log-group:/aws/lambda/notes-*"}`
   <details><summary>Answer</summary>

   Allow searching log events in any log group whose name starts with `/aws/lambda/notes-`, in that account and region.
   </details>

2. What's the difference between an identity-based and a resource-based policy?
   <details><summary>Answer</summary>

   Identity-based is attached to a user, group, or role and says what it can do. Resource-based is attached to a resource and names which principals can do what to it.
   </details>

3. Why is `iam:PassRole` on `*` dangerous?
   <details><summary>Answer</summary>

   It lets the identity give any role, including powerful ones, to a service it controls, and then act with that role's permissions. A classic privilege escalation.
   </details>

## Go deeper

- [IAM JSON policy reference](https://docs.aws.amazon.com/IAM/latest/UserGuide/reference_policies.html): every element.
- [Access Analyzer policy validation](https://docs.aws.amazon.com/IAM/latest/UserGuide/access-analyzer-policy-validation.html): what it checks.
