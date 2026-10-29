# Compute: Lambda and EC2

**Pillars:** ☁️ Cloud · 🪪 Identity

## Why this matters

Code has to run somewhere. AWS gives you two very different places. **Lambda** runs a function when something asks it to, and you never see a server. **EC2** gives you a whole virtual server, just like the Ubuntu VM you've used since Module 2, except it's in AWS and has an address on the internet.

The notes app runs on Lambda. You'll also run one EC2 instance, because many real companies still run servers, your Linux skills transfer directly, and a server on the internet teaches you something a lab never can: how fast strangers show up.

## Do it

### Lambda

**Console:** open **Lambda → Create function** and look at the options without creating anything: a runtime, an architecture, and an **execution role**. The role is the function's identity. Everything it can do in AWS comes from that role.

**Code:**

1. Write the function. Create `~/my-security-portfolio/notes-app/lambda/notes.py`:

   ```python
   """notes: a tiny notes API, run by AWS Lambda behind API Gateway."""

   import json


   def handler(event, context):
       return {
           "statusCode": 200,
           "headers": {"content-type": "application/json"},
           "body": json.dumps({"message": "hello from Lambda"}),
       }
   ```

   Lambda calls `handler` with an `event` (what triggered it) and a `context` (details about the run). It returns a response. That's the whole contract.

2. Add the **archive** provider to `main.tf`, inside `required_providers`. It zips your code for upload:

   ```hcl
       archive = {
         source  = "hashicorp/archive"
         version = "~> 2.8"
       }
   ```

3. Create `infra/lambda.tf`:

   ```hcl
   data "archive_file" "notes" {
     type        = "zip"
     source_file = "${path.module}/../lambda/notes.py"
     output_path = "${path.module}/build/notes.zip"
   }

   resource "aws_iam_role" "notes" {
     name = "${var.name}-lambda"

     assume_role_policy = jsonencode({
       Version = "2012-10-17"
       Statement = [{
         Effect    = "Allow"
         Principal = { Service = "lambda.amazonaws.com" }
         Action    = "sts:AssumeRole"
       }]
     })
   }

   resource "aws_iam_role_policy_attachment" "notes_logs" {
     role       = aws_iam_role.notes.name
     policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
   }

   resource "aws_cloudwatch_log_group" "notes" {
     name              = "/aws/lambda/${var.name}-api"
     retention_in_days = 14
   }

   resource "aws_lambda_function" "notes" {
     function_name    = "${var.name}-api"
     role             = aws_iam_role.notes.arn
     runtime          = "python3.14"
     handler          = "notes.handler"
     filename         = data.archive_file.notes.output_path
     source_code_hash = data.archive_file.notes.output_base64sha256
     timeout          = 10

     depends_on = [aws_cloudwatch_log_group.notes]
   }
   ```

   Read it in order:

   - The **role**, and its **trust policy** (`assume_role_policy`): "the Lambda service may use this role." That's who can *become* the role. Module 7 goes deep on this.
   - **AWSLambdaBasicExecutionRole**: the one permission it has so far, writing its own logs.
   - A **log group** that keeps logs for 14 days, instead of forever.
   - The **function**: Python 3.14, the zip, and `handler = "notes.handler"` (file `notes.py`, function `handler`). `source_code_hash` makes OpenTofu redeploy when the code changes.

4. Apply, then call it directly:

   ```bash
   tofu init
   tofu apply
   aws lambda invoke --function-name notes-api out.json && cat out.json
   aws logs tail /aws/lambda/notes-api --since 5m
   ```

   ```json
   {"statusCode": 200, "headers": {"content-type": "application/json"}, "body": "{\"message\": \"hello from Lambda\"}"}
   ```

   The log shows a `START`, `END`, and `REPORT` line for each run, with how long it took. No server, no patching, nothing running when no one's calling it.

### EC2

5. Make a key just for AWS, separate from your laptop-to-VM key:

   ```bash
   ssh-keygen -t ed25519 -f ~/.ssh/aws_lab -C "lab VM to AWS"
   ```

6. Find your public IP address, the one AWS will see you coming from, and save it in `terraform.tfvars` (which `.gitignore` keeps out of Git):

   ```bash
   echo "my_ip = \"$(curl -s https://checkip.amazonaws.com)\"" > terraform.tfvars
   cat terraform.tfvars
   ```

7. Add two variables to `variables.tf`:

   ```hcl
   variable "my_ip" {
     description = "Your public IP address, for SSH. Find it with: curl -s https://checkip.amazonaws.com"
     type        = string
   }

   variable "ssh_public_key_path" {
     description = "Public key for the EC2 instance"
     type        = string
     default     = "~/.ssh/aws_lab.pub"
   }
   ```

8. Create `infra/ec2.tf`:

   ```hcl
   data "aws_ssm_parameter" "ubuntu" {
     name = "/aws/service/canonical/ubuntu/server/26.04/stable/current/amd64/hvm/ebs-gp3/ami-id"
   }

   resource "aws_key_pair" "lab" {
     key_name   = "${var.name}-lab"
     public_key = file(pathexpand(var.ssh_public_key_path))
   }

   resource "aws_security_group" "ssh" {
     name        = "${var.name}-ssh"
     description = "SSH from my IP only"

     ingress {
       description = "SSH from my IP"
       from_port   = 22
       to_port     = 22
       protocol    = "tcp"
       cidr_blocks = ["${var.my_ip}/32"]
     }

     egress {
       description = "All outbound, for updates"
       from_port   = 0
       to_port     = 0
       protocol    = "-1"
       cidr_blocks = ["0.0.0.0/0"]
     }
   }

   resource "aws_instance" "lab" {
     ami                    = data.aws_ssm_parameter.ubuntu.value
     instance_type          = "t3.micro"
     key_name               = aws_key_pair.lab.key_name
     vpc_security_group_ids = [aws_security_group.ssh.id]

     metadata_options {
       http_tokens = "required" # IMDSv2 only
     }

     root_block_device {
       encrypted = true
     }

     tags = { Name = "${var.name}-lab" }
   }
   ```

   - The AMI (the disk image) comes from Canonical's official list, so you always get the current Ubuntu 26.04, not a stranger's image.
   - The **security group** is a firewall ([Module 4](../04-networking/08-firewalls.md)): SSH only from your IP, as a `/32`, one address.
   - `http_tokens = "required"` turns on **IMDSv2**, the fix for the Capital One technique from [lesson 2](02-shared-responsibility.md).
   - `t3.micro` is small, and covered by your Free plan credits. Anything left running still uses credits, so destroy it when you're done.

9. Add to `outputs.tf`:

   ```hcl
   output "lab_ip" {
     value = aws_instance.lab.public_ip
   }
   ```

10. Apply and log in:

    ```bash
    tofu apply
    ssh -i ~/.ssh/aws_lab ubuntu@$(tofu output -raw lab_ip)
    ```

    Wait a minute if it times out at first; the server is still booting. You're on an Ubuntu server in AWS. Everything from Module 2 works here.

11. On the EC2 instance, see IMDSv2 protect the role credentials. Without a token, the metadata service refuses:

    ```bash
    curl -s -o /dev/null -w "%{http_code}\n" http://169.254.169.254/latest/meta-data/
    ```

    ```
    401
    ```

    With a token, which requires a special `PUT` request first, it answers:

    ```bash
    TOKEN=$(curl -s -X PUT http://169.254.169.254/latest/api/token -H "X-aws-ec2-metadata-token-ttl-seconds: 60")
    curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/instance-id
    ```

    The Capital One attacker could make the server send simple `GET` requests. That's not enough to get a token. Type `exit` to leave the instance.

12. Commit:

    ```bash
    rm -f out.json
    git add ../lambda/notes.py main.tf variables.tf lambda.tf ec2.tf outputs.tf .terraform.lock.hcl
    git commit -m "Add Lambda function and EC2 lab instance"
    git push
    ```

## Break it

See how fast the internet finds you. **For 30 minutes only**, open SSH to everyone. In `ec2.tf`, change the security group's `cidr_blocks` to `["0.0.0.0/0"]` and apply.

Go do something else for half an hour. Then SSH in and look:

```bash
sudo journalctl -u ssh --since "35 minutes ago" | grep -c "Invalid user"
sudo journalctl -u ssh --since "35 minutes ago" | grep "Invalid user" | head
```

Strangers, from IP addresses you've never heard of, trying usernames like `admin`, `test`, and `oracle`. Usually within minutes. Your server isn't special; it's just on the internet.

Now run your [`logslayer`](../03-python/project.md) on it (copy it over with `scp`, or count with `grep`). It probably finds **zero** failed passwords. Ubuntu's AWS images allow key login only, so attackers are turned away before they can try a password, and sshd logs `Invalid user`, not `Failed password`. Your tool misses the attack. Write that down; you'll fix it in Module 9.

**Put it back to your IP** and apply. Then:

```bash
tofu destroy
```

## With Claude

Ask Claude Code, in `notes-app/infra`:

```text
Review ec2.tf for security problems. Don't change it.
```

**Check the work:** it should notice that SSH is internet-facing at all, even from one IP, and might suggest **SSM Session Manager**, which needs no open port. (You'll do exactly that in Module 8.) Does it say anything that's wrong for this file, like "IMDSv2 isn't enforced," when `http_tokens = "required"` is right there? Does it suggest a bigger instance type? That costs money and isn't a security fix. Check each finding against the code.

## Check yourself

1. Who patches the operating system for Lambda? For EC2?
   <details><summary>Answer</summary>

   AWS for Lambda. You for EC2: it's a server you run.
   </details>

2. What's a Lambda execution role?
   <details><summary>Answer</summary>

   The IAM role the function runs as. Every AWS action the function can take comes from the role's permissions.
   </details>

3. What does IMDSv2 protect, and how?
   <details><summary>Answer</summary>

   The instance's role credentials, available from the metadata service. IMDSv2 requires a token from a `PUT` request first, which stops attacks that can only make the server send simple `GET` requests.
   </details>

## Go deeper

- [Lambda: execution role](https://docs.aws.amazon.com/lambda/latest/dg/lambda-intro-execution-role.html): what the role is for, and what goes in it.
- [EC2: use IMDSv2](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/configuring-instance-metadata-service.html): how the metadata service works and why v2 matters.
