# Encryption at rest and in transit

**Pillars:** ☁️ Cloud · 🪪 Identity

## Why this matters

Encryption protects data in two places. **At rest**: on a disk, in a bucket, in a database, so a stolen drive or a misplaced backup is useless. **In transit**: moving over a network, so nobody in between can read it, as you proved with a packet capture in [Module 4](../04-networking/09-seeing-the-traffic.md).

In AWS, most encryption at rest is now on by default. That's good, and it's also why people stop thinking about it. The real questions are who controls the **keys**, and whether anything still accepts unencrypted connections.

## Do it

1. **Check encryption at rest on everything you've built:**

   ```bash
   cd ~/my-security-portfolio/notes-app/infra && tofu apply
   aws s3api get-bucket-encryption --bucket "$(tofu output -raw files_bucket)" \
     --query 'ServerSideEncryptionConfiguration.Rules[0].ApplyServerSideEncryptionByDefault'
   aws dynamodb describe-table --table-name notes-notes --query 'Table.SSEDescription'
   aws sqs get-queue-attributes --queue-url "$(aws sqs get-queue-url --queue-name notes-events --query QueueUrl --output text)" \
     --attribute-names SqsManagedSseEnabled
   INSTANCE=$(aws ec2 describe-instances --filters Name=tag:Name,Values=notes-lab Name=instance-state-name,Values=running \
     --query 'Reservations[0].Instances[0].InstanceId' --output text)
   aws ec2 describe-volumes --filters Name=attachment.instance-id,Values=$INSTANCE --query 'Volumes[].Encrypted'
   ```

   S3: `AES256` (S3-managed keys, on by default since 2023). DynamoDB: `null`, which means encrypted with a key **AWS owns** (always on; you can't turn it off). SQS: `true`. The server's disk: `true`, because you set `encrypted = true` in Module 6.

2. **Learn who holds the key.** AWS encryption at rest uses **KMS** (Key Management Service). Three kinds of key:

   | Key type | Who manages it | Cost | You can… |
   |---|---|---|---|
   | **AWS owned** | AWS, shared across accounts | Free | Nothing. You can't see or audit it. |
   | **AWS managed** (like `aws/ssm`) | AWS, in your account | Free | See it, and see its use in CloudTrail |
   | **Customer managed** | You | About $1/month per key, plus requests | Control who can use it with a key policy, rotate it, disable it, delete it |

   ```bash
   aws kms list-aliases --query 'Aliases[].AliasName' --output table
   ```

   The `aws/...` aliases are AWS-managed keys that services created for you, like `aws/ssm`, which encrypted your SecureString parameter in Module 6. A **customer-managed** key is how a company proves to auditors that **it** controls access to its data: disable the key, and nobody, including AWS, can read what it protects. This course doesn't create one to stay at $0, but you'll see them at work. Write the three kinds in `security/encryption.md`.

3. **Require encryption in transit.** S3 still accepts plain HTTP if you ask for it. Make the files bucket refuse. Add to `s3.tf`:

   ```hcl
   resource "aws_s3_bucket_policy" "files_tls_only" {
     bucket = aws_s3_bucket.files.id

     policy = jsonencode({
       Version = "2012-10-17"
       Statement = [{
         Sid       = "DenyUnencryptedTransport"
         Effect    = "Deny"
         Principal = "*"
         Action    = "s3:*"
         Resource  = [aws_s3_bucket.files.arn, "${aws_s3_bucket.files.arn}/*"]
         Condition = { Bool = { "aws:SecureTransport" = "false" } }
       }]
     })
   }
   ```

   "Deny anything, from anyone, that isn't over TLS." It's a Deny, so it can't make the bucket public, and it overrides any Allow. Apply.

4. **Check the rest of the app's transit encryption:** the API Gateway and CloudFront addresses are HTTPS-only by default, and CloudFront redirects HTTP to HTTPS (`viewer_protocol_policy = "redirect-to-https"`). Write each piece of the app, and how its traffic is encrypted, in `encryption.md`.

5. Commit `s3.tf` and your notes.

## Break it

Ask S3 for a file over plain HTTP, with valid credentials. The CLI lets you force an `http://` endpoint:

```bash
BUCKET=$(tofu output -raw files_bucket)
echo "transit test" | aws s3 cp - "s3://$BUCKET/transit.txt"
aws s3 cp "s3://$BUCKET/transit.txt" - --endpoint-url http://s3.us-east-1.amazonaws.com
```

```
An error occurred (AccessDenied) when calling the GetObject operation: Access Denied
```

Same identity, same object, same permissions. Over HTTPS it works; over HTTP it's denied. Your credentials were valid, but the request would have crossed the network in the clear, and the bucket refused. Try it over HTTPS (without `--endpoint-url`) to confirm.

## With Claude

Ask Claude Code:

```text
Should the notes app use a customer-managed KMS key for the DynamoDB table?
Give me the arguments for and against, including cost, and what changes in
the OpenTofu code.
```

**Check the work:** a good answer weighs control and auditability (a key policy, CloudTrail records of every use, the ability to disable it) against cost (about $1/month plus requests) and risk (delete the key and the data is gone **forever**). Did Claude mention that last one? It's the scariest property of a customer-managed key, and the reason key deletion has a mandatory waiting period. Check the price it quotes against the [KMS pricing page](https://aws.amazon.com/kms/pricing/).

## Check yourself

1. What does encryption at rest protect against? In transit?
   <details><summary>Answer</summary>

   At rest: someone getting the stored data (a disk, a backup, a snapshot) without access through AWS. In transit: someone reading or changing data as it crosses a network.
   </details>

2. Why might a company pay for a customer-managed KMS key when AWS-owned encryption is free?
   <details><summary>Answer</summary>

   Control and proof: they decide who can use the key, see every use in CloudTrail, and can disable it to cut off access to the data.
   </details>

3. How do you make an S3 bucket refuse non-HTTPS requests?
   <details><summary>Answer</summary>

   A bucket policy that denies all actions when `aws:SecureTransport` is `false`.
   </details>

## Go deeper

- [AWS KMS concepts](https://docs.aws.amazon.com/kms/latest/developerguide/concepts.html): keys, key policies, and envelope encryption.
