# Module 7 quiz

Answer each question out loud or on paper *before* you open the answer.

1. A user logs in successfully but gets `403 Forbidden` opening a page. Authentication or authorization?
   <details><summary>Answer</summary>

   Authorization. They proved who they are (authentication passed); they aren't allowed to see that page.
   </details>

2. Name four kinds of AWS principal, and which one this course says humans should never use with long-lived keys.
   <details><summary>Answer</summary>

   Root user, IAM user, IAM role, federated user (and AWS services). Humans never get long-lived access keys on IAM users; use `aws login` or single sign-on.
   </details>

3. Why do permissions go on groups instead of users? And can a group be the `Principal` in a bucket policy?
   <details><summary>Answer</summary>

   Groups keep access consistent and make team changes a single membership change, preventing privilege creep. No: groups aren't principals, so a resource policy can't name one.
   </details>

4. Read this as a sentence: `{"Effect":"Allow","Action":["s3:GetObject"],"Resource":"arn:aws:s3:::notes-files/*","Condition":{"Bool":{"aws:SecureTransport":"true"}}}`
   <details><summary>Answer</summary>

   Allow downloading any object in the `notes-files` bucket, but only over an encrypted (HTTPS) connection.
   </details>

5. **The `s3:*` challenge.** Alice has `Allow s3:* on *` and `Deny s3:* on arn:aws:s3:::payroll/*`. Can she read `payroll/salaries.csv`? Can she delete the `payroll` bucket itself?
   <details><summary>Answer</summary>

   She can't read the file: the explicit Deny on `payroll/*` wins. She **can** delete the bucket (if it's empty), because the Deny only covers objects (`payroll/*`), not the bucket ARN (`payroll`). A complete guardrail lists both.
   </details>

6. What's the difference between `implicitDeny` and `explicitDeny`?
   <details><summary>Answer</summary>

   Implicit: nothing allowed it. Explicit: a Deny statement matched. Explicit deny overrides any Allow; implicit deny is overridden by an Allow.
   </details>

7. A pipeline uses an IAM user with an access key stored in its settings. What's wrong, and what should it use instead?
   <details><summary>Answer</summary>

   A long-lived key that never expires and can leak from wherever it's stored. It should assume a role with short-lived credentials, for CI through OIDC (Module 8).
   </details>

8. **Find three problems in this trust policy** on a role with AdministratorAccess:

   ```json
   { "Effect": "Allow", "Principal": {"AWS": "*"}, "Action": "sts:AssumeRole" }
   ```

   <details><summary>Answer</summary>

   It trusts every AWS account in the world; there's no External ID or other condition; and the role it guards has AdministratorAccess. Together: anyone can become admin of the account.
   </details>

9. CloudTrail shows `assumed-role/vendor-auditor/vendor-audit` making calls. How do you find the original identity?
   <details><summary>Answer</summary>

   Find the `AssumeRole` event for that session. Its `userIdentity` is the caller, and its response contains the temporary access key. Search CloudTrail by that key for everything the session did.
   </details>

10. An AI agent needs to read one Lambda function's logs to help debug it. Describe its role.
    <details><summary>Answer</summary>

    Its own role, assumable only by you, with `logs:FilterLogEvents` on that function's log group only, short sessions, an explicit Deny on secrets, and a session name that marks its calls in CloudTrail.
    </details>

## Challenge

Play [flaws2.cloud](http://flaws2.cloud/), both the attacker and defender paths. It's a free, intentionally vulnerable AWS environment built to be attacked, so it's on your [allowed list](../00-start-here/02-ethics-and-the-law.md). Every level is an identity or configuration mistake from this module.

For each level, write one line in your stuck log: what the mistake was, and which lesson's control would have prevented it.
