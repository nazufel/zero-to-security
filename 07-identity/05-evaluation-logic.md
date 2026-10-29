# Permissions and evaluation logic

**Pillars:** 🪪 Identity · ☁️ Cloud

## Why this matters

A single request can be touched by many policies: the user's, their groups', the resource's, a permissions boundary. You need to **predict** the result, not guess, and AWS follows three rules, in order, every time. Learn them and you can answer "why was this allowed?" and "why was this denied?" on the first try. Interviewers love this topic for exactly that reason.

## The rules

1. **An explicit `Deny` wins.** If any policy that applies says Deny, the answer is Deny. Nothing overrides it.
2. **Otherwise, an `Allow` allows.** If at least one applicable policy says Allow, the answer is Allow.
3. **Otherwise, it's denied.** If nothing says anything, it's an **implicit deny**. AWS starts from "no."

So: **explicit deny > allow > implicit deny.** Deny wins so you can put guardrails in place that a broad Allow somewhere else can't accidentally undo.

## Do it

You'll predict, then test with the **IAM Policy Simulator**, which evaluates real policies without making real requests. Free, and nothing can break.

1. **Predict first.** Write your answer for each before you run anything:

   | # | Who | Action | On | Prediction |
   |---|---|---|---|---|
   | 1 | `practice-ana` | `dynamodb:Scan` | the notes table | |
   | 2 | `practice-ana` | `dynamodb:DeleteItem` | the notes table | |
   | 3 | `practice-dev` | `lambda:UpdateFunctionCode` | `notes-api` | |
   | 4 | `practice-dev` | `lambda:UpdateFunctionCode` | a function called `billing-api` | |
   | 5 | `practice-aud` | `iam:ListUsers` | `*` | |

2. **Test.** Set some variables, then simulate case 1:

   ```bash
   ACCT=$(aws sts get-caller-identity --query Account --output text)
   TABLE="arn:aws:dynamodb:us-east-1:$ACCT:table/notes-notes"

   aws iam simulate-principal-policy \
     --policy-source-arn "arn:aws:iam::$ACCT:user/practice-ana" \
     --action-names dynamodb:Scan dynamodb:DeleteItem \
     --resource-arns "$TABLE" \
     --query 'EvaluationResults[].[EvalActionName,EvalDecision]' --output table
   ```

   ```
   -------------------------------------------
   |         SimulatePrincipalPolicy         |
   +-----------------------+-----------------+
   |  dynamodb:Scan        |  allowed        |
   |  dynamodb:DeleteItem  |  implicitDeny   |
   +-----------------------+-----------------+
   ```

   `implicitDeny`: nothing allowed it. Run cases 3 to 5 the same way, changing the user, actions, and resource. Score your predictions.

3. **Add a condition.** Conditions narrow an Allow to certain situations. A common one: **require MFA** for anything destructive. Add this statement to the developers' policy in `team.tf`:

   ```hcl
         {
           Sid      = "DenyCodeChangesWithoutMFA"
           Effect   = "Deny"
           Action   = "lambda:UpdateFunctionCode"
           Resource = "*"
           Condition = {
             BoolIfExists = { "aws:MultiFactorAuthPresent" = "false" }
           }
         },
   ```

   "Deny code changes when MFA wasn't used." Apply, then simulate case 3 with and without MFA in the request context:

   ```bash
   aws iam simulate-principal-policy \
     --policy-source-arn "arn:aws:iam::$ACCT:user/practice-dev" \
     --action-names lambda:UpdateFunctionCode \
     --resource-arns "arn:aws:lambda:us-east-1:$ACCT:function:notes-api" \
     --context-entries "ContextKeyName=aws:MultiFactorAuthPresent,ContextKeyValues=false,ContextKeyType=boolean" \
     --query 'EvaluationResults[].[EvalActionName,EvalDecision]' --output table
   ```

   `explicitDeny`. Change `false` to `true`: `allowed`. The Allow in the same policy didn't matter, because an explicit Deny always wins. That's a **guardrail**.

   Other conditions you'll see at work: `aws:SourceIp` (only from the office network), `aws:RequestedRegion` (only in our region), and **tags**, like "developers can only change functions tagged `team = notes`." Granting access by tags is called **ABAC** (attribute-based access control), and it's how large companies avoid writing a policy per resource.

4. Save your prediction table, with the results and anything you got wrong, in `identity/evaluation-practice.md`, and commit it with `team.tf`.

## Break it

The challenge from this module's plan. Predict the answer, then prove it. Alice has these two policies:

```json
{ "Effect": "Allow", "Action": "s3:*", "Resource": "*" }
```

```json
{ "Effect": "Deny", "Action": "s3:*", "Resource": ["arn:aws:s3:::payroll", "arn:aws:s3:::payroll/*"] }
```

Can Alice read `s3://payroll/salaries.csv`? Can she read `s3://notes-files/note.txt`? Test with `simulate-custom-policy`, which takes policies as JSON instead of a real user:

```bash
aws iam simulate-custom-policy \
  --policy-input-list '{"Version":"2012-10-17","Statement":[{"Effect":"Allow","Action":"s3:*","Resource":"*"}]}' \
                      '{"Version":"2012-10-17","Statement":[{"Effect":"Deny","Action":"s3:*","Resource":["arn:aws:s3:::payroll","arn:aws:s3:::payroll/*"]}]}' \
  --action-names s3:GetObject \
  --resource-arns arn:aws:s3:::payroll/salaries.csv arn:aws:s3:::notes-files/note.txt \
  --query 'EvaluationResults[].[EvalResourceName,EvalDecision]' --output table
```

<details><summary>Answer</summary>

`payroll/salaries.csv`: **explicitDeny**. `notes-files/note.txt`: **allowed**. The Deny wins for payroll; the broad Allow covers everything else. Note that the deny names both the bucket and `/*`. Leave off `/*` and the objects inside wouldn't be covered. That mistake turns a guardrail into decoration.
</details>

## With Claude

Ask Claude Code to write a test for your design:

```text
Write a Bash script, test-team-access.sh, that uses
`aws iam simulate-principal-policy` to check each practice user against the
access in team.tf: one action each group SHOULD be allowed and one it should
NOT. Print PASS or FAIL per check, and exit non-zero if any fail.
```

**Check the work:**

- Run it. Does every check pass? If one fails, is the script wrong, or your policy?
- Break a policy on purpose (add `dynamodb:DeleteItem` to analysts) and run it again. Does the "should NOT" check catch it? A test that can't fail is worthless ([Module 3, lesson 11](../03-python/11-testing.md)).
- Is the account ID hard-coded, or looked up?

Keep the script. It's a regression test for your identity design, and you'll show it in the project.

## Check yourself

1. One policy allows `s3:GetObject` on a bucket. Another denies `s3:*` on the same bucket. Result?
   <details><summary>Answer</summary>

   Denied. An explicit Deny always wins.
   </details>

2. No policy mentions `sqs:DeleteQueue` at all. Can the user delete a queue?
   <details><summary>Answer</summary>

   No. Implicit deny: AWS denies anything that isn't explicitly allowed.
   </details>

3. Why write guardrails as Deny statements instead of just leaving out the Allow?
   <details><summary>Answer</summary>

   A missing Allow can be undone by someone adding a broad Allow elsewhere. An explicit Deny can't be overridden by any Allow.
   </details>

## Go deeper

- [IAM policy evaluation logic](https://docs.aws.amazon.com/IAM/latest/UserGuide/reference_policies_evaluation-logic.html): the full flowchart, including boundaries and resource policies.
- [IAM Policy Simulator](https://policysim.aws.amazon.com/): the same tool, in a browser.
