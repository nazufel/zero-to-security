# Single sign-on into AWS

**Pillars:** 🪪 Identity · ☁️ Cloud

## Why this matters

This finishes the identity story from [Module 7](../../07-identity/02-principals.md). There, the course said humans should never have long-lived AWS keys, and at work, people log in through single sign-on and get a role. Now you'll build exactly that: people sign in to Okta, click AWS, and land in your account **as a role**, for one session, with no IAM user at all. When someone leaves, deactivating them in Okta ([lesson 2](02-users-and-groups.md)) also ends their AWS access.

The standard that makes it work is **SAML**: Okta signs a statement saying "this is Jordan, and they may use this role," and AWS checks the signature.

## Do it

1. **Create the app in Okta.** **Applications → Create App Integration → SAML 2.0.** Name it `AWS (notes lab)`. On the SAML settings page:

   | Setting | Value |
   |---|---|
   | Single sign-on URL | `https://signin.aws.amazon.com/saml` |
   | Audience URI (SP Entity ID) | `urn:amazon:webservices` |
   | Name ID format | EmailAddress |
   | Application username | Email |

   Leave the attribute statements for step 4. Finish, then on the app's **Sign On** tab, find the **metadata** for the app (a "Metadata URL" or "View SAML setup instructions" link) and save the XML as `okta-metadata.xml` in `~/my-security-portfolio/notes-app/infra/`. It contains Okta's public signing certificate, not a secret.

2. **Tell AWS to trust Okta.** In `notes-app/infra/`, create `okta-sso.tf`:

   ```hcl
   # Sign in to AWS through Okta (SAML): people get a role for one session, with no IAM user at all.

   resource "aws_iam_saml_provider" "okta" {
     name                   = "okta"
     saml_metadata_document = file("${path.module}/okta-metadata.xml")
   }

   resource "aws_iam_role" "okta_view_only" {
     name                 = "okta-view-only"
     max_session_duration = 3600

     assume_role_policy = jsonencode({
       Version = "2012-10-17"
       Statement = [{
         Effect    = "Allow"
         Principal = { Federated = aws_iam_saml_provider.okta.arn }
         Action    = "sts:AssumeRoleWithSAML"
         Condition = {
           StringEquals = { "SAML:aud" = "https://signin.aws.amazon.com/saml" }
         }
       }]
     })
   }

   resource "aws_iam_role_policy_attachment" "okta_view_only" {
     role       = aws_iam_role.okta_view_only.name
     policy_arn = "arn:aws:iam::aws:policy/job-function/ViewOnlyAccess"
   }

   output "okta_role_attribute" {
     description = "Paste this (with the quotes) as the Role attribute value in the Okta app"
     value       = "\"${aws_iam_role.okta_view_only.arn},${aws_iam_saml_provider.okta.arn}\""
   }
   ```

   Read the trust policy against [Module 7](../../07-identity/07-impersonation.md): the principal is the **SAML provider**, the action is `AssumeRoleWithSAML`, and the condition checks the assertion was meant for AWS sign-in. No user, no key. View-only, because it's a lab.

   ```bash
   tofu apply
   tofu output -raw okta_role_attribute
   ```

   > Adding a SAML provider doesn't need AWS Organizations or IAM Identity Center, so it doesn't affect your [Free plan credits](../../appendix/aws-cost-safety.md).

3. **Add the AWS attributes to the Okta app.** Edit the app's SAML settings, and add two **attribute statements**:

   | Name | Value |
   |---|---|
   | `https://aws.amazon.com/SAML/Attributes/Role` | The output from step 2, quotes included |
   | `https://aws.amazon.com/SAML/Attributes/RoleSessionName` | `user.email` |

   The first says which role, through which provider. The second puts the person's email on every AWS session, so CloudTrail shows **who**.

4. **Assign it to the group, not to people.** On the app's **Assignments** tab, assign the `AWS View Only` group from lesson 2. Add Jordan to that group.

5. **Sign in as Jordan.** In your private window, open Jordan's Okta dashboard and click the AWS app. You land in the AWS console. Top right: `okta-view-only/you+jordan@...`. Try to change anything: denied. Look at anything: allowed.

6. **Find it in CloudTrail**, from your VM, a few minutes later:

   ```bash
   aws cloudtrail lookup-events --lookup-attributes AttributeKey=EventName,AttributeValue=AssumeRoleWithSAML \
     --max-results 5 --output json | jq -r '.Events[].CloudTrailEvent | fromjson | "\(.eventTime) \(.requestParameters.roleSessionName // .userIdentity.userName)"'
   ```

   Jordan's sign-in, with Jordan's email, through Okta. Commit `okta-sso.tf` and `okta-metadata.xml`.

## Break it

**Offboard Jordan, and watch AWS access go.** In the admin console, remove Jordan from `AWS View Only`. In the private window, refresh Jordan's dashboard: the AWS app is gone. Try the app's sign-in link directly: Okta refuses.

Note what's still true: if Jordan was **already** signed in to the AWS console, that session lasts until it expires (up to an hour here, `max_session_duration`). Removing access in the IdP stops **new** sessions; it doesn't end ones already running. Write in `okta/notes.md` why short session lengths matter for leavers, and what you'd do for an urgent termination. (In AWS, an admin can revoke a role's active sessions from the IAM console: **Revoke active sessions** on the role.)

## With Claude

Ask Claude Code:

```text
Read notes-app/infra/okta-sso.tf. I want developers in Okta to get a
different AWS role than everyone else. How should I change the Okta app
and the OpenTofu code? Keep least privilege. Don't apply anything.
```

**Check the work:** a good answer adds a second role with its own trust policy, and passes **both** roles in the Role attribute only to users in the right group (Okta can make the attribute value depend on group membership). Does any role trust the SAML provider without the `SAML:aud` condition? Did it give developers `AdministratorAccess` "to keep it simple"? Check the Okta expression syntax it suggests against [Okta's expression language docs](https://developer.okta.com/docs/reference/okta-expression-language/); a wrong expression usually fails at sign-in, with an unhelpful error.

## Check yourself

1. What does SAML do in this setup?
   <details><summary>Answer</summary>

   Okta sends AWS a signed statement saying who the user is and which role they may use. AWS checks the signature against the provider you registered and gives a temporary session for that role.
   </details>

2. Why is this better than an IAM user for each person?
   <details><summary>Answer</summary>

   No long-lived passwords or keys in AWS, MFA enforced in one place, and removing someone in Okta removes their AWS access.
   </details>

3. You remove someone from the AWS group in Okta. Can they still use AWS right now?
   <details><summary>Answer</summary>

   Only through a session they already had, until it expires. New sign-ins are refused. For urgent cases, revoke the role's active sessions in IAM.
   </details>

## Go deeper

- [AWS: enabling SAML federated users to access the console](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_providers_enable-console-saml.html)
