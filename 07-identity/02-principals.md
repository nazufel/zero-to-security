# Principals

**Pillars:** 🪪 Identity · ☁️ Cloud

## Why this matters

A **principal** is anyone or anything that can make a request in AWS. When you investigate an incident, the first question is always "which principal did this?", and the answer could be a person, a pipeline, a Lambda function, or an AI agent. Each kind of principal gets credentials differently, and the differences decide what an attacker gets when they steal them.

## The principals

| Principal | What it is | Credentials | Use it for |
|---|---|---|---|
| **Root user** | The account's owner | Email, password, MFA | Almost nothing: a few account-level tasks. Lock it away. |
| **IAM user** | A long-term identity in your account | A password and/or **long-lived access keys** | At work, rarely. In this course, your one `admin` user, with no keys. |
| **IAM role** | An identity with no permanent credentials. Someone or something **assumes** it. | **Temporary** credentials, issued on demand, that expire | Services, pipelines, AI agents, and humans at most companies |
| **Federated user** | A person who logs in through a company identity provider (like Okta or Entra ID), then gets a role | Temporary, via the provider | Humans at work |
| **AWS service** | Like `lambda.amazonaws.com`, acting for you | Assumes a role you allow it to | Your Lambda functions, EC2 instances |

**The course's opinion: humans never get long-lived access keys.** Use `aws login` (as you have since Module 6), or your company's single sign-on. An access key is a password that never expires and is usually stored in a file. That's why leaked keys are behind so many real incidents.

## Do it

1. **See your account's principals.** List the users and roles:

   ```bash
   aws iam list-users --query 'Users[].[UserName,CreateDate]' --output table
   aws iam list-roles --query 'Roles[].[RoleName]' --output table
   ```

   One user (`admin`), and more roles than you might expect: `notes-lambda`, `notes-audit`, `claude-readonly`, plus several starting with `AWSServiceRoleFor...`. Those are **service-linked roles** that AWS created so its own services can act in your account.

2. **Read a role's trust policy**, the rule for who can become it:

   ```bash
   aws iam get-role --role-name notes-lambda --query 'Role.AssumeRolePolicyDocument'
   aws iam get-role --role-name claude-readonly --query 'Role.AssumeRolePolicyDocument'
   ```

   One trusts the Lambda **service**. The other trusts your `admin` **user**. A role is only as safe as its trust policy: if it trusts "anyone in this account," anyone in this account can become it.

3. **See every credential in the account at once** with the credential report:

   ```bash
   aws iam generate-credential-report
   sleep 5
   aws iam get-credential-report --query Content --output text | base64 -d | cut -d, -f1,4,8,9,10
   ```

   (Base64 again: encoding, not encryption.) For each user: password enabled, MFA active, and whether access keys exist. On your account: root and `admin` have MFA, and nobody has an access key. That's the goal. Auditors run this report on every account they review.

4. Add a principals table to `identity/identity-notes.md`, listing every principal in your account, what kind it is, and how it gets credentials.

## Break it

Do the thing this course says never to do, and see what it leaves behind. Create a user for a "deploy pipeline," with an access key:

```bash
aws iam create-user --user-name ci-deploy
aws iam create-access-key --user-name ci-deploy
```

```json
{
    "AccessKey": {
        "UserName": "ci-deploy",
        "AccessKeyId": "AKIA...",
        "Status": "Active",
        "SecretAccessKey": "wJalr...",
        "CreateDate": "2026-10-29T..."
    }
}
```

That `SecretAccessKey` is shown **once**. Somebody now has to store it somewhere: a CI system's settings, a `.env` file, a password manager, a Slack message. It never expires. If it leaks, it works for whoever finds it until someone notices.

Regenerate the credential report: `access_key_1_active` is now `true` for `ci-deploy`. Remember this user. In the [sample CloudTrail](../06-cloud-aws/samples/cloudtrail-events.json) from Module 6, a user called `ci-deploy` was poking around from a strange IP. That's how this story ends, and in Module 9, you'll run that incident.

Delete it now:

```bash
KEY=$(aws iam list-access-keys --user-name ci-deploy --query 'AccessKeyMetadata[0].AccessKeyId' --output text)
aws iam delete-access-key --user-name ci-deploy --access-key-id "$KEY"
aws iam delete-user --user-name ci-deploy
```

The right answer for a pipeline is a **role** it assumes with a short-lived token, with no key stored anywhere. You'll build exactly that in Module 8.

## With Claude

Ask Claude Code (with the read-only AWS tools from Module 6):

```text
Using the AWS tools, list every IAM user and role in my account. For each,
say what kind of principal it is, who or what can use it, and whether it
has any long-lived credentials.
```

**Check the work:** compare with your own table. Can Claude see the credential report with ViewOnlyAccess, or does it say it can't? (If it claims to know about access keys without being able to read them, it's guessing.) Did it explain the `AWSServiceRoleFor...` roles correctly, or suggest deleting them? Don't: AWS services need them.

```bash
git add identity/identity-notes.md
git commit -m "Add principals inventory"
git push
```

## Check yourself

1. What's the difference between an IAM user and an IAM role?
   <details><summary>Answer</summary>

   A user is a long-term identity that can have a permanent password and access keys. A role has no permanent credentials: it's assumed, and gives temporary credentials that expire.
   </details>

2. Why does this course say humans never get long-lived access keys?
   <details><summary>Answer</summary>

   They never expire and usually live in files, so when they leak, they keep working until someone notices. `aws login` and single sign-on give temporary credentials instead.
   </details>

3. What decides who can assume a role?
   <details><summary>Answer</summary>

   Its trust policy.
   </details>

## Go deeper

- [IAM identities](https://docs.aws.amazon.com/IAM/latest/UserGuide/id.html): users, groups, and roles, officially.
- [IAM credential report](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_getting-report.html): every column explained.
