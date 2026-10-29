# Groups

**Pillars:** 🪪 Identity · ☁️ Cloud

## Why this matters

When someone changes teams, what should change about their access? If permissions are attached to each person directly, the honest answer is "nobody knows," and people collect access over the years like keys on a keyring. Auditors call it **privilege creep**, and it's how an intern ends up able to delete production.

The fix is the same in Linux and AWS: **permissions go on groups, never directly on people.** Moving teams means changing one group membership, and "what can a developer do?" has one answer you can read.

## Do it

You'll design access for the notes app's (pretend) team: **developers** who deploy and debug the functions, **analysts** who read notes, and **auditors** who check configuration and change nothing.

1. In `notes-app/infra`, create `team.tf`:

   ```hcl
   # The notes app team: people get permissions through groups, never directly.

   resource "aws_iam_group" "team" {
     for_each = toset(["developers", "analysts", "auditors"])
     name     = "notes-${each.key}"
   }

   # Developers: deploy and debug the app's functions, read its logs
   resource "aws_iam_group_policy" "developers" {
     name  = "notes-developer"
     group = aws_iam_group.team["developers"].name

     policy = jsonencode({
       Version = "2012-10-17"
       Statement = [
         {
           Sid      = "ManageNotesFunctions"
           Effect   = "Allow"
           Action   = ["lambda:GetFunction", "lambda:UpdateFunctionCode", "lambda:InvokeFunction"]
           Resource = "arn:aws:lambda:${var.region}:${data.aws_caller_identity.current.account_id}:function:${var.name}-*"
         },
         {
           Sid      = "ReadNotesLogs"
           Effect   = "Allow"
           Action   = ["logs:FilterLogEvents", "logs:GetLogEvents", "logs:DescribeLogStreams"]
           Resource = "arn:aws:logs:${var.region}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/${var.name}-*"
         },
       ]
     })
   }

   # Analysts: read notes, nothing else
   resource "aws_iam_group_policy" "analysts" {
     name  = "notes-analyst"
     group = aws_iam_group.team["analysts"].name

     policy = jsonencode({
       Version = "2012-10-17"
       Statement = [{
         Sid      = "ReadNotes"
         Effect   = "Allow"
         Action   = ["dynamodb:GetItem", "dynamodb:Scan"]
         Resource = aws_dynamodb_table.notes.arn
       }]
     })
   }

   # Auditors: see how everything is configured and read the audit trail, change nothing
   resource "aws_iam_group_policy_attachment" "auditors" {
     group      = aws_iam_group.team["auditors"].name
     policy_arn = "arn:aws:iam::aws:policy/SecurityAudit"
   }

   # One practice user per group, with no password and no keys: they exist only to test policies
   resource "aws_iam_user" "practice" {
     for_each = { dev = "developers", ana = "analysts", aud = "auditors" }
     name     = "practice-${each.key}"
   }

   resource "aws_iam_user_group_membership" "practice" {
     for_each = { dev = "developers", ana = "analysts", aud = "auditors" }
     user     = aws_iam_user.practice[each.key].name
     groups   = [aws_iam_group.team[each.value].name]
   }
   ```

   The practice users have no password and no keys, so nobody can log in as them. They exist so you can **test** what each group can do (lesson 5). IAM is free, so this costs nothing.

2. Apply, and look at it from both sides:

   ```bash
   tofu apply
   aws iam list-groups-for-user --user-name practice-ana --query 'Groups[].GroupName'
   aws iam get-group --group-name notes-analysts --query 'Users[].UserName'
   ```

3. **Move someone between teams.** The analyst becomes a developer. In `team.tf`, change `ana = "analysts"` to `ana = "developers"` in the membership block, then:

   ```bash
   tofu plan
   ```

   One change: a group membership. Nothing about the user's permissions had to be rewritten, removed, or remembered. Put it back and apply.

4. Add a section to `identity/identity-notes.md`: a table of the three groups, what each can do in one sentence, and why each permission is there.

5. Commit:

   ```bash
   git add team.tf
   git commit -m "Add team groups for the notes app"
   git push
   ```

## Break it

Two gotchas that catch people who know Linux groups.

**Groups can't contain groups.** Try to make "all staff" a group that contains the three team groups:

```bash
aws iam add-user-to-group --group-name notes-developers --user-name notes-analysts
```

```
An error occurred (NoSuchEntity) when calling the AddUserToGroup operation: The user with name notes-analysts cannot be found.
```

IAM only puts **users** in groups. There's no nesting. If you need "everyone gets X," attach X to each group, or (at work) handle it in your company's identity provider.

**Groups aren't principals.** Try to write a bucket policy that names a group:

```json
"Principal": { "AWS": "arn:aws:iam::123456789012:group/notes-analysts" }
```

AWS rejects it as an invalid principal. A group is a way to **attach** permissions to users; it can't **make** a request, so a resource policy can't name it. To grant a group access to a resource, give the group an identity-based policy, like `team.tf` does.

## With Claude

Ask Claude Code:

```text
Read team.tf. Is each group least-privilege for its job as described in the
comments? Point out anything too broad or too narrow. Don't change files.
```

**Check the work:**

- `SecurityAudit` is an AWS-managed policy. Look at what it allows: `aws iam get-policy-version --policy-arn arn:aws:iam::aws:policy/SecurityAudit --version-id $(aws iam get-policy --policy-arn arn:aws:iam::aws:policy/SecurityAudit --query Policy.DefaultVersionId --output text) --query 'PolicyVersion.Document.Statement[0].Action' | head -20`. Is it broader than "read config"? Did Claude know that, or assume?
- Developers can `UpdateFunctionCode`. Could a developer use that to read notes, even though they have no DynamoDB permission? (Yes: deploy code that reads the table, using the **function's** role.) Did Claude spot that? It's a real and subtle escalation path. Write it in your notes.

## Check yourself

1. Why attach permissions to groups instead of users?
   <details><summary>Answer</summary>

   It keeps access consistent and readable, and changing someone's role means changing one membership, which stops privilege creep.
   </details>

2. Can an IAM group contain another group?
   <details><summary>Answer</summary>

   No. Groups contain only users.
   </details>

3. A developer can update Lambda code but has no DynamoDB access. Can they read the notes table?
   <details><summary>Answer</summary>

   Effectively yes: they can deploy code that reads it using the function's role. Permission to change code that runs as a role is close to having that role.
   </details>

## Go deeper

- [IAM user groups](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_groups.html): including the limits on groups.
