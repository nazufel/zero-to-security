# Network segmentation

**Pillars:** ☁️ Cloud

## Why this matters

In 2013, attackers broke into Target through a heating and air-conditioning vendor's access, then moved across the network until they reached the cash registers. About 40 million card numbers were stolen. The vendor's foothold was never supposed to reach payment systems, but nothing on the network stopped it.

**Segmentation** means splitting a network so each part can only reach what it needs. When one part falls, the attacker is stuck there. You designed this for an office in [Module 4](../04-networking/project.md). Now you'll build the cloud version: **tiers**, where each one accepts traffic only from the tier in front of it.

## Do it

1. **The three-tier pattern.** A classic web app has a web tier (faces the internet), an app tier (business logic), and a data tier (the database). In AWS, a security group can allow traffic **from another security group**, by ID, instead of from an IP range. That's how tiers are built: "the database accepts connections only from things in the app tier's security group," wherever those things are, however many there are.

   Create `notes-app/infra/segmentation.tf`:

   ```hcl
   # Three-tier segmentation, the cloud version of the Module 4 office design.
   # Each tier accepts traffic only from the tier in front of it.

   resource "aws_security_group" "web" {
     name        = "${var.name}-web-tier"
     description = "Web tier: HTTPS from the internet"
     vpc_id      = aws_vpc.lab.id

     ingress {
       description = "HTTPS from anywhere"
       from_port   = 443
       to_port     = 443
       protocol    = "tcp"
       cidr_blocks = ["0.0.0.0/0"]
     }
   }

   resource "aws_security_group" "app" {
     name        = "${var.name}-app-tier"
     description = "App tier: only from the web tier"
     vpc_id      = aws_vpc.lab.id

     ingress {
       description     = "App port, from the web tier only"
       from_port       = 8080
       to_port         = 8080
       protocol        = "tcp"
       security_groups = [aws_security_group.web.id]
     }
   }

   resource "aws_security_group" "db" {
     name        = "${var.name}-db-tier"
     description = "Database tier: only from the app tier"
     vpc_id      = aws_vpc.lab.id

     ingress {
       description     = "PostgreSQL, from the app tier only"
       from_port       = 5432
       to_port         = 5432
       protocol        = "tcp"
       security_groups = [aws_security_group.app.id]
     }
   }

   resource "aws_network_acl" "private" {
     vpc_id     = aws_vpc.lab.id
     subnet_ids = [aws_subnet.private.id]

     # Only traffic from inside the VPC, in either direction
     ingress {
       rule_no    = 100
       protocol   = "-1"
       action     = "allow"
       cidr_block = aws_vpc.lab.cidr_block
       from_port  = 0
       to_port    = 0
     }

     egress {
       rule_no    = 100
       protocol   = "-1"
       action     = "allow"
       cidr_block = aws_vpc.lab.cidr_block
       from_port  = 0
       to_port    = 0
     }
   }
   ```

   Security groups and NACLs are free, so you can build the whole pattern without running a single server or database. Two layers: the security groups chain the tiers, and the private subnet's NACL refuses anything from outside the VPC, a backstop if a security group is ever misconfigured.

2. Apply, and look at the chain from the CLI:

   ```bash
   tofu apply
   aws ec2 describe-security-groups --filters Name=group-name,Values=notes-db-tier \
     --query 'SecurityGroups[0].IpPermissions[0].UserIdGroupPairs[0].GroupId'
   aws ec2 describe-security-groups --filters Name=group-name,Values=notes-app-tier --query 'SecurityGroups[0].GroupId'
   ```

   The database tier's only source is the app tier's group ID. Trace every possible path from the internet to port 5432 and write them in `security/segmentation.md`. (There's exactly one, through both other tiers.)

3. **Where the notes app sits.** The notes app is mostly **serverless**: Lambda, DynamoDB, and SQS don't live in your VPC at all. Their segmentation is done with **IAM**: each function's role can reach only its own table, queue, and logs. Write a short paragraph in `segmentation.md` comparing the two: network segmentation (who can **connect**) and identity segmentation (who can **call**). Modern cloud apps rely on both.

4. **Find anything open to the world.** This is a query you'll run on every account you ever review:

   ```bash
   aws ec2 describe-security-groups --filters Name=ip-permission.cidr,Values=0.0.0.0/0 \
     --query 'SecurityGroups[].[GroupName,IpPermissions[].FromPort]' --output text
   ```

   Only the web tier, on 443. Every line in that output needs a reason.

5. Commit `segmentation.tf` and your notes.

## Break it

Make the most common segmentation mistake: someone "just needs to connect to the database for a minute" from home. In `segmentation.tf`, add to the database tier's security group:

```hcl
  ingress {
    description = "temp: my laptop"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
```

`0.0.0.0/0` because they didn't know their IP. Apply and rerun the query from step 4: the database tier is now open to the internet, skipping both tiers in front of it. "Temporary" rules like this one are found in real accounts years later. In lesson 14, a scanner will flag it before it's ever applied. Remove it and apply.

## With Claude

Paste your [Module 4 office design](../04-networking/project.md) (subnets and firewall rules) into Claude Code, and ask:

```text
Translate this office network design into AWS: a VPC, subnets, security
groups, and NACLs in OpenTofu. Use security group references between tiers
instead of CIDR ranges wherever possible. Don't apply anything.
```

**Check the work:** read it against your original rules, one by one. Does every "deny" in your design have a matching absence (or NACL deny) in Claude's code? Did it add `0.0.0.0/0` anywhere you didn't allow internet access? Did it add a NAT gateway (which [costs money by the hour](../appendix/aws-cost-safety.md))? Run `tofu plan` on it in a scratch folder if you want to see it validated, but don't apply it.

## Check yourself

1. What does it mean for a security group to allow traffic from another security group?
   <details><summary>Answer</summary>

   Any resource in the source group can connect, by group membership instead of IP address. It's how tiers are chained.
   </details>

2. The notes app's Lambda functions aren't in the VPC. How are they segmented?
   <details><summary>Answer</summary>

   By IAM: each function's role can only reach its own resources. That's identity segmentation.
   </details>

3. Why add a NACL on the private subnet if the security groups already restrict access?
   <details><summary>Answer</summary>

   Defense in depth. If a security group is misconfigured (like the `0.0.0.0/0` rule), the NACL still blocks traffic from outside the VPC.
   </details>

## Go deeper

- [AWS: security group referencing](https://docs.aws.amazon.com/vpc/latest/userguide/security-group-rules.html#security-group-referencing): how group-to-group rules work.
