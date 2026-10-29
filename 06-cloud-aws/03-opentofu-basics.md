# OpenTofu basics

**Pillars:** ☁️ Cloud · 🤖 AI

## Why this matters

You can build everything in AWS by clicking. Then someone asks "what do we have, and how is it configured?" and nobody knows. **Infrastructure as Code** (IaC) means writing your cloud resources down as code files: reviewed like code, tracked in Git, built and torn down with one command. The code is your inventory, and you can't protect what you don't know you have.

**OpenTofu** is the free, open-source tool this course uses for IaC. It reads `.tf` files and makes AWS match them.

## Do it

1. **Install OpenTofu** in your VM. Read the installer first:

   ```bash
   curl --proto '=https' --tlsv1.2 -fsSL https://get.opentofu.org/install-opentofu.sh -o install-opentofu.sh
   less install-opentofu.sh
   chmod +x install-opentofu.sh
   ./install-opentofu.sh --install-method deb
   rm -f install-opentofu.sh
   tofu version
   ```

   > **Last verified:** 2026-10-29 with OpenTofu 1.13 ([install docs](https://opentofu.org/docs/intro/install/deb/)).

2. **Start the notes app project.** You'll build it across this whole module:

   ```bash
   mkdir -p ~/my-security-portfolio/notes-app/{infra,lambda,frontend}
   cd ~/my-security-portfolio/notes-app/infra
   ```

3. **Keep state out of Git, first.** Create `.gitignore`:

   ```text
   # Never commit state: it can contain secrets and your account's inventory
   *.tfstate
   *.tfstate.*
   .terraform/
   build/
   *.tfvars
   ```

   You'll see why in Break it.

4. Create `main.tf`, which says which **provider** (the plugin that talks to AWS) to use:

   ```hcl
   terraform {
     required_version = ">= 1.10"

     required_providers {
       aws = {
         source  = "hashicorp/aws"
         version = "~> 6.0"
       }
     }
   }

   provider "aws" {
     region = var.region

     default_tags {
       tags = {
         Project   = "notes-app"
         ManagedBy = "opentofu"
       }
     }
   }

   data "aws_caller_identity" "current" {}
   ```

   `default_tags` labels everything this project creates, so you can always find it in the console. `data` reads information from AWS instead of creating something: here, your account ID.

5. Create `variables.tf`, the project's inputs:

   ```hcl
   variable "region" {
     description = "The one AWS region everything in this course goes in"
     type        = string
     default     = "us-east-1"
   }

   variable "name" {
     description = "Prefix for every resource name"
     type        = string
     default     = "notes"
   }
   ```

6. Create `hello.tf` with your first **resource**, something to create:

   ```hcl
   resource "aws_s3_bucket" "hello" {
     bucket_prefix = "${var.name}-hello-"
   }

   output "hello_bucket" {
     value = aws_s3_bucket.hello.bucket
   }
   ```

   Read the resource line as **type** (`aws_s3_bucket`), then **local name** (`hello`), which is how you refer to it elsewhere: `aws_s3_bucket.hello.bucket`. `bucket_prefix` lets AWS add a unique ending, since bucket names are global. An **output** prints a value after you apply.

7. The loop you'll use for every change: **init, plan, apply, destroy.**

   ```bash
   tofu init
   ```

   Downloads the AWS provider and writes `.terraform.lock.hcl`, which pins its exact version and hashes, just like `uv.lock` in [Module 3](../03-python/09-packages.md). **Commit the lock file.**

   ```bash
   tofu plan
   ```

   ```
   OpenTofu will perform the following actions:

     # aws_s3_bucket.hello will be created
     + resource "aws_s3_bucket" "hello" {
         + bucket_prefix = "notes-hello-"
         ...
       }

   Plan: 1 to add, 0 to change, 0 to destroy.
   ```

   **Read every plan.** `+` creates, `~` changes, `-` destroys, and `-/+` destroys and recreates. The last line is the summary. Nothing has happened yet.

   ```bash
   tofu apply
   ```

   It shows the plan again and asks you to type `yes`. Then:

   ```
   Apply complete! Resources: 1 added, 0 changed, 0 destroyed.

   Outputs:

   hello_bucket = "notes-hello-20261029213045123400000001"
   ```

   Check it exists: `aws s3 ls`. Then run `tofu plan` again: "No changes." The code and AWS match.

8. Tear it down:

   ```bash
   tofu destroy
   ```

   Type `yes`. Everything this project created is gone. That's your end-of-session habit from [lesson 1](01-account-setup.md), and why IaC makes cloud costs safe: one command removes it all.

9. Delete `hello.tf` (it was practice) and commit the rest:

   ```bash
   rm hello.tf
   git add .gitignore main.tf variables.tf .terraform.lock.hcl
   git status
   git commit -m "Start notes-app infrastructure"
   git push
   ```

   Check `git status` before committing: no `.tfstate` file and no `.terraform/` folder should be listed.

## Break it

See why state must never be committed. OpenTofu keeps a **state file**, `terraform.tfstate`, that records everything it manages, so it knows what exists. Make a resource with a secret in it. Create `oops.tf`:

```hcl
resource "aws_ssm_parameter" "oops" {
  name  = "/notes/oops"
  type  = "SecureString"
  value = "FAKE-password-hunter2"
}
```

```bash
tofu apply
grep -A3 '"value"' terraform.tfstate
```

```
            "value": "FAKE-password-hunter2",
```

AWS stores that parameter encrypted. **The state file stores it in plain text.** Commit the state, and the secret is in your Git history forever ([Module 0](../00-start-here/03-git-and-github.md)). Even without secrets, state is a full inventory of your account: resource names, IDs, IP addresses, an attacker's map.

That's why your `.gitignore` blocks state, and why in lesson 8 you'll create real secrets **outside** OpenTofu. At work, state lives in a locked-down, encrypted remote store, never in Git. Clean up:

```bash
tofu destroy
rm oops.tf
```

## With Claude

In `~/my-security-portfolio/notes-app/infra`, ask Claude Code:

```text
Add an S3 bucket to this OpenTofu project that I could use for storing
logs. Show me the plan you expect before you write the file.
```

**Check the work:** read the file it writes, then run `tofu plan` yourself and compare with what Claude said would happen. Does the plan create only what you asked for? Did it add `acl = "public-read"`, or turn off Block Public Access "so it works"? Did it hard-code a region or bucket name instead of using `var.name` and `var.region`? Then `tofu apply`, check it in the console, and `tofu destroy`. Delete the file when you're done. **Console → Code → Claude**: you saw S3 in the console in lesson 2, wrote it as code here, and now reviewed Claude's version. Every lesson in this module follows that pattern.

## Check yourself

1. What do `tofu plan` and `tofu apply` each do?
   <details><summary>Answer</summary>

   `plan` shows what would change, without changing anything. `apply` shows the plan again and, after you type `yes`, makes the changes.
   </details>

2. In a plan, what does `-/+` mean?
   <details><summary>Answer</summary>

   Destroy and recreate. For a database or bucket, that can mean losing data, so stop and read why.
   </details>

3. Why must `terraform.tfstate` never be committed?
   <details><summary>Answer</summary>

   It can contain secrets in plain text, and it's a complete map of your infrastructure. Once committed, it stays in Git history.
   </details>

4. Should you commit `.terraform.lock.hcl`?
   <details><summary>Answer</summary>

   Yes. It pins the exact provider versions and hashes, so everyone gets the same, verified provider.
   </details>

## Go deeper

- [OpenTofu documentation](https://opentofu.org/docs/): the language, the CLI, and remote state.
- [AWS provider docs](https://search.opentofu.org/provider/hashicorp/aws/latest): every resource type, with examples. You'll live here.
