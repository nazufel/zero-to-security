# Storage: S3

**Pillars:** ☁️ Cloud

## Why this matters

**S3** stores files, called **objects**, in **buckets**. It's one of the most used services in AWS, and for years it was one of the most leaked. In 2017 alone, researchers found exposed S3 buckets belonging to Verizon, Accenture, and a US defense contractor, full of customer records, passwords, and internal files. None of them were hacked. The buckets were set to public, and anyone who found the name could download everything.

AWS has since made buckets private by default. This lesson shows you the guardrails, and what it takes to turn them off.

## Do it

**Console:** open **S3** and look at any bucket's **Permissions** tab, if you have one left over, or start creating one and stop before you finish. Find **Block Public Access**. Four switches, all on.

**Code:**

1. In `~/my-security-portfolio/notes-app/infra`, create `s3.tf`. This bucket will hold files for the notes app:

   ```hcl
   resource "aws_s3_bucket" "files" {
     bucket_prefix = "${var.name}-files-"
     force_destroy = true # lab only: lets `tofu destroy` delete a bucket that still has objects
   }

   resource "aws_s3_bucket_public_access_block" "files" {
     bucket = aws_s3_bucket.files.id

     block_public_acls       = true
     block_public_policy     = true
     ignore_public_acls      = true
     restrict_public_buckets = true
   }

   resource "aws_s3_bucket_versioning" "files" {
     bucket = aws_s3_bucket.files.id

     versioning_configuration {
       status = "Enabled"
     }
   }
   ```

   Three resources. The bucket, Block Public Access written down explicitly (so a reviewer can see it, rather than trust a default), and **versioning**, which keeps every old version of every object.

2. Create `outputs.tf`:

   ```hcl
   output "files_bucket" {
     value = aws_s3_bucket.files.bucket
   }
   ```

3. Plan, read the plan, and apply:

   ```bash
   tofu plan
   tofu apply
   ```

4. Use it. Save the bucket name in a shell variable, upload a file, and list it:

   ```bash
   BUCKET=$(tofu output -raw files_bucket)
   echo "my first note" > note.txt
   aws s3 cp note.txt "s3://$BUCKET/note.txt"
   aws s3 ls "s3://$BUCKET/"
   ```

5. Try to read it as a stranger on the internet would, with no credentials:

   ```bash
   curl -s "https://$BUCKET.s3.amazonaws.com/note.txt"
   ```

   ```xml
   <?xml version="1.0" encoding="UTF-8"?>
   <Error><Code>AccessDenied</Code><Message>Access Denied</Message>...</Error>
   ```

   Private. Exactly right.

6. See versioning save you. Overwrite the file, then delete it:

   ```bash
   echo "oops, overwritten" > note.txt
   aws s3 cp note.txt "s3://$BUCKET/note.txt"
   aws s3 rm "s3://$BUCKET/note.txt"
   aws s3 ls "s3://$BUCKET/"
   aws s3api list-object-versions --bucket "$BUCKET" --query 'Versions[].[VersionId,LastModified]' --output table
   ```

   `ls` shows nothing: the file looks deleted. But both versions are still there. Delete in a versioned bucket only adds a "delete marker." Ransomware that deletes or encrypts your files in S3 can't touch old versions unless it also has permission to delete versions. You'll see backups again in [Dig Deeper](../dig-deeper/).

7. Commit:

   ```bash
   rm note.txt
   git add s3.tf outputs.tf
   git commit -m "Add S3 bucket for note files"
   git push
   ```

## Break it

Make the bucket public on purpose, and watch the guardrail stop you. Add to `s3.tf`:

```hcl
resource "aws_s3_bucket_policy" "oops" {
  bucket = aws_s3_bucket.files.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = "*"
      Action    = "s3:GetObject"
      Resource  = "${aws_s3_bucket.files.arn}/*"
    }]
  })
}
```

`Principal = "*"` means **anyone on the internet**. Apply it:

```bash
tofu apply
```

Roughly:

```
Error: putting S3 Bucket (notes-files-...) Policy: operation error S3: PutBucketPolicy,
api error AccessDenied: ... because public policies are blocked by the BlockPublicPolicy
block public access setting.
```

Block Public Access refused. Now imagine someone "fixes" that error the fast way. Set `block_public_policy` and `restrict_public_buckets` to `false`, and apply again. This time it succeeds. Upload a file and try the stranger's `curl` from step 5:

```bash
echo "secret customer data" > leak.txt
aws s3 cp leak.txt "s3://$BUCKET/leak.txt"
curl -s "https://$BUCKET.s3.amazonaws.com/leak.txt"
```

```
secret customer data
```

That's on the internet now. Two lines of code, and a reviewer would have to read the plan carefully to notice. That's exactly how those 2017 headlines happened.

(If the apply still fails, your **account-level** Block Public Access is on: S3 → Block Public Access settings for this account. That's the even safer setting. Leave it on.)

Put it right **now**: delete the `aws_s3_bucket_policy` block, set both settings back to `true`, `tofu apply`, and check that `curl` is denied again. Then `rm leak.txt`.

## With Claude

Ask Claude Code, in `notes-app/infra`:

```text
I want to host a public website's images from the files bucket in s3.tf.
Change the code to make that work.
```

**Check the work:** this is a request where the "easy" answer is the dangerous one. Does Claude turn off Block Public Access and add `Principal = "*"` on the whole bucket? Read the plan for `-/+` and for every `false`. A better answer keeps the bucket private and serves files through **CloudFront** with an origin access control, which is what you'll build in the project. Did Claude suggest that, or did it just make the error go away? **Don't apply** anything that makes the bucket public. Throw the change away with `git checkout -- s3.tf`.

## Check yourself

1. What does Block Public Access do?
   <details><summary>Answer</summary>

   It overrides bucket policies and ACLs that would make the bucket or its objects public, so a single mistake in a policy can't expose data.
   </details>

2. You deleted a file from a versioned bucket. Is it gone?
   <details><summary>Answer</summary>

   No. Deleting adds a delete marker; earlier versions remain and can be restored, unless someone deletes those versions too.
   </details>

3. A plan shows a bucket policy with `"Principal": "*"`. What does that mean?
   <details><summary>Answer</summary>

   The policy applies to anyone, including anonymous users on the internet. Combined with `s3:GetObject`, it makes the objects public.
   </details>

## Go deeper

- [S3 Block Public Access](https://docs.aws.amazon.com/AmazonS3/latest/userguide/access-control-block-public-access.html): the four settings, at bucket and account level.
