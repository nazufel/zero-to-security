# Impersonation: assuming roles

**Pillars:** 🪪 Identity · ☁️ Cloud

## Why this matters

Almost everything in AWS that isn't you is a role being **assumed**: your Lambda functions, your lab server, Claude, and, at most companies, every human who logs in through single sign-on. Assuming a role is a controlled form of impersonation: "for the next hour, I'm acting as this role."

That makes two skills essential. Setting up trust so only the right principal can assume a role, including outside companies who can be tricked. And tracing, in CloudTrail, **who really did it** when the logs only show the role's name.

## Do it

1. **Assume a role by hand.** Your `claude` profile has been doing this for you since Module 6. Do it yourself:

   ```bash
   ACCT=$(aws sts get-caller-identity --query Account --output text)
   aws sts assume-role \
     --role-arn "arn:aws:iam::$ACCT:role/claude-readonly" \
     --role-session-name practice-by-hand \
     --query 'Credentials.Expiration'
   ```

   You get a temporary access key, secret, and **session token**, valid for an hour (the command above only shows when they expire). Temporary keys start with `ASIA`; long-lived user keys start with `AKIA`. That one letter tells you a lot in an investigation.

2. **Set up a vendor.** Many companies let an outside vendor, say, a security auditing firm, into their AWS account through a role. The vendor's AWS account is trusted to assume it. Create `notes-app/infra/vendor.tf`:

   ```hcl
   # A role a (pretend) outside vendor assumes to audit the account.
   # The External ID stops the vendor from being tricked into using it for someone else.
   variable "vendor_external_id" {
     description = "A shared value the vendor must send when assuming the role"
     type        = string
     default     = "notes-app-7f3c9a"
   }

   resource "aws_iam_role" "vendor" {
     name = "vendor-auditor"

     assume_role_policy = jsonencode({
       Version = "2012-10-17"
       Statement = [{
         Effect    = "Allow"
         Principal = { AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root" }
         Action    = "sts:AssumeRole"
         Condition = {
           StringEquals = { "sts:ExternalId" = var.vendor_external_id }
         }
       }]
     })
   }

   resource "aws_iam_role_policy_attachment" "vendor" {
     role       = aws_iam_role.vendor.name
     policy_arn = "arn:aws:iam::aws:policy/SecurityAudit"
   }
   ```

   In real life, the `Principal` would be the **vendor's** account ID. You only have one account, so it trusts your own (`:root` here means "this account," not the root user), and you'll play the vendor.

3. **Understand the confused deputy.** The vendor has hundreds of customers, each with a role like this. The vendor's system assumes whichever role a customer gives it. Now an attacker signs up as a customer and, instead of their own role, gives the vendor **your** role's ARN. The vendor's system, trusted by you, dutifully assumes your role and shows the attacker your account. The vendor is the "deputy," tricked into using its power for the wrong person.

   The **External ID** stops it. The vendor generates a unique ID for each customer, you put it in your trust policy, and the vendor always sends the ID of the customer it's working for. The attacker's requests carry the attacker's ID, which doesn't match yours. Denied.

4. Apply, and play the vendor. Add a profile to `~/.aws/config`:

   ```ini
   [profile vendor]
   role_arn = arn:aws:iam::123456789012:role/vendor-auditor
   source_profile = lab
   external_id = notes-app-7f3c9a
   role_session_name = vendor-audit
   region = us-east-1
   ```

   ```bash
   tofu apply
   aws sts get-caller-identity --profile vendor
   aws iam list-roles --profile vendor --query 'length(Roles)'
   ```

   You're the vendor, auditing with SecurityAudit.

5. **Trace who really did it.** In CloudTrail, the vendor's calls show up as `assumed-role/vendor-auditor/vendor-audit`. But who assumed it? Find the `AssumeRole` event (wait a few minutes for it to appear):

   ```bash
   aws cloudtrail lookup-events --lookup-attributes AttributeKey=EventName,AttributeValue=AssumeRole --max-results 10 \
     --output json | jq -r '.Events[].CloudTrailEvent | fromjson
       | select(.requestParameters.roleArn | test("vendor"))
       | "\(.eventTime) caller=\(.userIdentity.arn) session=\(.requestParameters.roleSessionName) key=\(.responseElements.credentials.accessKeyId)"'
   ```

   ```
   2026-10-29T22:14:02Z caller=arn:aws:iam::123456789012:user/admin session=vendor-audit key=ASIA...
   ```

   Then follow that temporary key to everything it did:

   ```bash
   aws cloudtrail lookup-events --lookup-attributes AttributeKey=AccessKeyId,AttributeValue=ASIA... \
     --query 'Events[].[EventTime,EventName]' --output table
   ```

   The chain is: **who** called `AssumeRole` → the **temporary key** it got → every **action** taken with that key. When an incident shows a role doing something bad, this is how you find the human (or the stolen credential) behind it.

6. Commit `vendor.tf`.

## Break it

Be the attacker in the confused deputy story: assume the role **without** the External ID.

```bash
aws sts assume-role --role-arn "arn:aws:iam::$ACCT:role/vendor-auditor" --role-session-name attacker
```

```
An error occurred (AccessDenied) when calling the AssumeRole operation: User: arn:aws:iam::123456789012:user/admin
is not authorized to perform: sts:AssumeRole on resource: arn:aws:iam::123456789012:role/vendor-auditor
```

Even you, the account's admin, are denied, because the trust policy's condition isn't met. Now try with the wrong ID (`--external-id attackers-own-id`). Denied again.

Then the opposite mistake. Delete the `Condition` block from the trust policy, apply, and run the first command again. It works. That's a vendor role without an External ID: the exact setup the confused deputy attack needs. AWS's own guidance says to always use one for third-party roles. Put the condition back and apply.

## With Claude

Find three problems in a trust policy, the challenge from this module's plan. Show Claude this, and also try it yourself first:

```json
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Principal": { "AWS": "*" },
    "Action": "sts:AssumeRole",
    "Condition": { "StringLike": { "sts:ExternalId": "*" } }
  }]
}
```

```text
This is the trust policy on a role with AdministratorAccess, meant for our
backup vendor. Find every problem with it and explain the risk of each.
```

<details><summary>The problems</summary>

1. `"Principal": {"AWS": "*"}` trusts **every AWS account in the world**, not the vendor's.
2. The External ID condition uses `StringLike` with `*`, which matches any value, so it checks nothing.
3. A backup vendor doesn't need **AdministratorAccess**. That's the permissions policy, not the trust policy, but it's the biggest risk of all: anyone in the world could become an admin of your account.
</details>

**Check the work:** did Claude find all three? Did it notice that #1 plus #2 means anyone on the internet can become an admin, and rank it as critical? Ask it to write the corrected policy, then run that through `aws accessanalyzer validate-policy --policy-type RESOURCE_POLICY`. Note that Access Analyzer may not flag everything: a valid policy can still be a bad idea.

## Check yourself

1. What does a role's trust policy control?
   <details><summary>Answer</summary>

   Who can assume the role. Its permissions policies control what the role can do once assumed.
   </details>

2. Explain the confused deputy problem and the fix, in two sentences.
   <details><summary>Answer</summary>

   A trusted service (the deputy) is tricked by one of its customers into using its access on another customer's account. An External ID, unique per customer and required by the trust policy, makes the service prove which customer it's acting for.
   </details>

3. CloudTrail shows `assumed-role/vendor-auditor/vendor-audit` deleting something. How do you find who was behind it?
   <details><summary>Answer</summary>

   Find the `AssumeRole` event for that session; its `userIdentity` is the caller, and its response holds the temporary access key. Then search CloudTrail by that access key to see everything the session did.
   </details>

## Go deeper

- [The confused deputy problem](https://docs.aws.amazon.com/IAM/latest/UserGuide/confused-deputy.html): AWS's explanation, with diagrams.
- [Access to third-party accounts with External ID](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_common-scenarios_third-party.html): how vendors should set it up.
