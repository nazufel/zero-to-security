# Service accounts

**Pillars:** 🪪 Identity · ☁️ Cloud

## Why this matters

Software needs identities too: a pipeline that deploys, a server that reads files, a function that writes to a database. These are **service accounts**. The number one finding in real AWS security reviews is a service account done the old way: an IAM user, with an access key, pasted into a config file or a CI system years ago, with more permissions than anyone remembers.

In AWS, the right service account is a **role**. The software gets temporary credentials automatically, they rotate on their own, and there's no key to copy, commit, or leak.

## Do it

You already have two good service accounts: the Lambda functions' roles from Module 6. Now give your lab server one, the right way.

1. Create `notes-app/infra/instance_profile.tf`:

   ```hcl
   # The lab server's identity: a role, delivered through an instance profile
   resource "aws_iam_role" "lab" {
     name = "${var.name}-lab-server"

     assume_role_policy = jsonencode({
       Version = "2012-10-17"
       Statement = [{
         Effect    = "Allow"
         Principal = { Service = "ec2.amazonaws.com" }
         Action    = "sts:AssumeRole"
       }]
     })
   }

   resource "aws_iam_role_policy" "lab" {
     name = "read-files-bucket"
     role = aws_iam_role.lab.id

     policy = jsonencode({
       Version = "2012-10-17"
       Statement = [
         {
           Effect   = "Allow"
           Action   = "s3:ListBucket"
           Resource = aws_s3_bucket.files.arn
         },
         {
           Effect   = "Allow"
           Action   = "s3:GetObject"
           Resource = "${aws_s3_bucket.files.arn}/*"
         },
       ]
     })
   }

   resource "aws_iam_instance_profile" "lab" {
     name = "${var.name}-lab-server"
     role = aws_iam_role.lab.name
   }
   ```

   Compare it with the policy Claude wrote in [lesson 4](04-policies.md). `ListBucket` on the bucket, `GetObject` on the objects. An **instance profile** is the wrapper EC2 uses to hand a role to a server.

2. In `ec2.tf`, give the instance its profile:

   ```hcl
     iam_instance_profile   = aws_iam_instance_profile.lab.name
   ```

3. Apply, put a file in the bucket, then SSH in:

   ```bash
   tofu apply
   echo "hello from the files bucket" > hello.txt
   aws s3 cp hello.txt "s3://$(tofu output -raw files_bucket)/hello.txt" && rm hello.txt
   tofu output -raw files_bucket; echo
   ssh -i ~/.ssh/aws_lab ubuntu@$(tofu output -raw lab_ip)
   ```

4. On the instance, install the CLI and use the role. **No `aws login`, no keys, no config:**

   ```bash
   sudo snap install aws-cli --classic
   aws sts get-caller-identity
   ```

   ```json
   {
       "Arn": "arn:aws:sts::123456789012:assumed-role/notes-lab-server/i-0abc123..."
   }
   ```

   The CLI found the role's credentials through the metadata service (IMDSv2, from [Module 6](../06-cloud-aws/05-compute.md)). The session name is the instance's ID, so CloudTrail shows exactly which server made each call.

   Set the bucket name you printed before logging in (the role can't list all your buckets, only use this one):

   ```bash
   BUCKET=notes-files-...
   aws s3 cp "s3://$BUCKET/hello.txt" -
   aws s3 rm "s3://$BUCKET/hello.txt"
   ```

   The read works. The delete is `AccessDenied`: the role can read, not delete.

5. See how short-lived the credentials are:

   ```bash
   TOKEN=$(curl -s -X PUT http://169.254.169.254/latest/api/token -H "X-aws-ec2-metadata-token-ttl-seconds: 60")
   curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/iam/security-credentials/notes-lab-server | grep -E '"(Type|Expiration)"'
   ```

   (The `grep` shows only two fields. The full response includes the secret key itself, and secrets don't belong on your screen, in your scrollback, or in a screenshot.) An `Expiration` a few hours out. AWS rotates them automatically. If one leaks, it's useless soon after.

6. `exit`, then commit:

   ```bash
   git add instance_profile.tf ec2.tf
   git commit -m "Give the lab server its own role"
   git push
   ```

## Break it

Find the anti-pattern in the wild. The Module 6 [sample CloudTrail](../06-cloud-aws/samples/cloudtrail-events.json) has a user called `ci-deploy`. Look at its identity type:

```bash
jq -r '.Events[] | .CloudTrailEvent | fromjson | select(.userIdentity.arn | test("ci-deploy")) | .userIdentity.type' \
  ~/my-security-portfolio/cloud/cloudtrail-events.json | sort -u
```

```
IAMUser
```

A pipeline, running as an **IAM user**, which means a long-lived access key stored somewhere. And it's being used from an IP address nobody recognizes, with a generic `python-requests` user agent. That's what a leaked service account key looks like in the logs. Compare it with your lab server's calls: `AssumedRole`, with the instance ID as the session name, credentials that expire in hours.

Write, in `identity/identity-notes.md`, three reasons the role is safer. You'll investigate the `ci-deploy` incident for real in Module 9.

## With Claude

Ask Claude Code:

```text
A GitHub Actions workflow needs to deploy the notes app with OpenTofu. How
should it authenticate to AWS? Compare at least two options and recommend one.
```

**Check the work:** the right answer is **OIDC**: GitHub Actions gets a short-lived token, and AWS lets it assume a role whose trust policy only accepts tokens from your repository and branch. No stored keys. You'll build it in Module 8. If Claude's first answer is "create an IAM user and store the access key in GitHub Secrets," that's the common, outdated pattern this lesson is about. Did it mention OIDC at all? Did it scope the trust policy to a specific repo and branch, or allow any GitHub repository? (That last mistake has been found in real companies.)

## Check yourself

1. What's an instance profile?
   <details><summary>Answer</summary>

   The wrapper that delivers an IAM role to an EC2 instance, so software on it gets temporary credentials automatically.
   </details>

2. Why is an IAM user with an access key a bad service account?
   <details><summary>Answer</summary>

   The key never expires, has to be stored and copied somewhere, and keeps working if it leaks. A role gives temporary, automatically rotated credentials with nothing to store.
   </details>

3. In CloudTrail, how can you tell a call came from a role, and from which instance?
   <details><summary>Answer</summary>

   `userIdentity.type` is `AssumedRole`, and the ARN ends with the session name, which for EC2 is the instance ID.
   </details>

## Go deeper

- [IAM roles for EC2](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/iam-roles-for-amazon-ec2.html): how instance profiles and the metadata service deliver credentials.
