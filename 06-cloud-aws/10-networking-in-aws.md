# Networking in AWS

**Pillars:** ☁️ Cloud

## Why this matters

Everything from [Module 4](../04-networking/) exists in AWS with a new name. A **VPC** is your own private network. **Subnets** are its slices, with CIDR blocks you now know how to pick. **Route tables** are `ip route`. **Security groups** are `ufw`. **NACLs** are a second, simpler firewall on each subnet.

Your EC2 instance has been sitting in the "default VPC" AWS creates for every account. In real work, nobody puts anything important there. In this lesson you build your own network, and move the server into it.

## Module 4 → AWS

| Module 4 | AWS | Notes |
|---|---|---|
| A network with a CIDR block | **VPC** | Usually a `/16`, like `10.0.0.0/16` |
| A subnet | **Subnet** | A slice of the VPC, in one availability zone |
| The default gateway to the internet | **Internet gateway** | Attached to the VPC |
| `ip route` | **Route table** | A subnet is **public** if its route table sends `0.0.0.0/0` to an internet gateway |
| `ufw` on a server | **Security group** | Attached to a resource. **Stateful**: replies are allowed automatically. Allow rules only. |
| A firewall for the whole office network | **Network ACL (NACL)** | Attached to a subnet. **Stateless**: replies need their own rule. Allow and deny rules, checked in number order. |

## Do it

**Console:** open **VPC → Your VPCs** and find the **default VPC**. Look at its subnets: every one is public. Then open **VPC → Create VPC** and look at the choices, but don't create anything. (If you ever create one in the console, **don't** add a NAT gateway: it bills by the hour, [even when idle](../appendix/aws-cost-safety.md).)

**Code:**

1. Create `infra/vpc.tf`:

   ```hcl
   resource "aws_vpc" "lab" {
     cidr_block           = "10.0.0.0/16"
     enable_dns_hostnames = true

     tags = { Name = "${var.name}-vpc" }
   }

   resource "aws_subnet" "public" {
     vpc_id                  = aws_vpc.lab.id
     cidr_block              = "10.0.1.0/24"
     map_public_ip_on_launch = true

     tags = { Name = "${var.name}-public" }
   }

   resource "aws_subnet" "private" {
     vpc_id     = aws_vpc.lab.id
     cidr_block = "10.0.2.0/24"

     tags = { Name = "${var.name}-private" }
   }

   resource "aws_internet_gateway" "lab" {
     vpc_id = aws_vpc.lab.id
   }

   resource "aws_route_table" "public" {
     vpc_id = aws_vpc.lab.id

     route {
       cidr_block = "0.0.0.0/0"
       gateway_id = aws_internet_gateway.lab.id
     }
   }

   resource "aws_route_table_association" "public" {
     subnet_id      = aws_subnet.public.id
     route_table_id = aws_route_table.public.id
   }

   resource "aws_network_acl" "public" {
     vpc_id     = aws_vpc.lab.id
     subnet_ids = [aws_subnet.public.id]

     # SSH in, from you only
     ingress {
       rule_no    = 100
       protocol   = "tcp"
       action     = "allow"
       cidr_block = "${var.my_ip}/32"
       from_port  = 22
       to_port    = 22
     }

     # Replies to connections the instance started (updates, downloads).
     # NACLs are stateless, so return traffic needs its own rule.
     ingress {
       rule_no    = 200
       protocol   = "tcp"
       action     = "allow"
       cidr_block = "0.0.0.0/0"
       from_port  = 1024
       to_port    = 65535
     }

     egress {
       rule_no    = 100
       protocol   = "-1"
       action     = "allow"
       cidr_block = "0.0.0.0/0"
       from_port  = 0
       to_port    = 0
     }
   }
   ```

   Read it against the table:

   - A `/16` VPC, with two `/24` subnets carved out of it ([Module 4, lesson 2](../04-networking/02-subnets-and-cidr.md)).
   - The **public** subnet's route table sends `0.0.0.0/0` to the internet gateway. The **private** subnet has no such route: nothing in it can reach the internet, or be reached from it. That's where databases go in a server-based app.
   - The NACL on the public subnet: SSH in from you, replies in on the **ephemeral ports** (1024–65535, the temporary ports your machine uses for its side of outgoing connections), everything out. Anything else is denied by the NACL's built-in final rule.

2. Move the server in. In `ec2.tf`, add `vpc_id` to the security group:

   ```hcl
     vpc_id      = aws_vpc.lab.id
   ```

   And `subnet_id` to the instance:

   ```hcl
     subnet_id              = aws_subnet.public.id
   ```

3. Plan, and **read it carefully**:

   ```bash
   tofu plan
   ```

   The instance and its security group show `-/+`: **replaced**. You can't move a running server to another network; AWS builds a new one. That's fine for a lab. At work, that line in a plan is where you stop and ask what's on the old server.

4. Apply, SSH in, and check the new address:

   ```bash
   tofu apply
   ssh -i ~/.ssh/aws_lab ubuntu@$(tofu output -raw lab_ip)
   ip -brief address
   ```

   The private address is now in `10.0.1.0/24`, your public subnet. `sudo apt update` works, so the internet route and the NACL's return-traffic rule are doing their jobs. Type `exit`.

5. Commit:

   ```bash
   git add vpc.tf ec2.tf
   git commit -m "Move the lab server into its own VPC"
   git push
   ```

## Break it

See **stateless** in action. In `vpc.tf`, delete the NACL's rule 200 (the ephemeral ports), apply, and SSH in. SSH still works: rule 100 lets you in, and the instance's replies go **out**, which egress allows. Now, on the instance:

```bash
sudo apt update
```

It hangs, then fails. The instance sends its request out to the update servers, fine. Their **replies** come back to an ephemeral port, and the NACL has no rule allowing that. A security group would have allowed the reply automatically, because it remembers the outgoing connection. A NACL remembers nothing.

This exact mistake ("the server can't download anything, but I can SSH in") is a classic cloud ticket. Press `Ctrl+C`, `exit`, put rule 200 back, and apply.

## With Claude

Ask Claude Code:

```text
Read vpc.tf and ec2.tf. Draw the network as a text diagram: VPC, subnets,
route tables, gateway, NACL, security group, and the instance. Then list
every path traffic can take in and out.
```

**Check the work:** compare its diagram with the code, resource by resource. Does it show a NAT gateway that doesn't exist? (A common invention.) Does it say the private subnet can reach the internet? It can't: no route. Does it describe the NACL as stateful? It isn't. Fix the diagram where it's wrong and keep it; you'll draw the full architecture in the project.

## Check yourself

1. What makes a subnet "public"?
   <details><summary>Answer</summary>

   Its route table sends `0.0.0.0/0` to an internet gateway.
   </details>

2. Security group vs. NACL: which is stateful, and what does that mean?
   <details><summary>Answer</summary>

   Security groups are stateful: if a connection is allowed one way, the replies are allowed automatically. NACLs are stateless: replies need their own rule.
   </details>

3. Why no NAT gateway in this course?
   <details><summary>Answer</summary>

   It bills by the hour and per gigabyte, even when idle. Nothing in the notes app needs one: the serverless parts don't run in the VPC, and the lab server sits in the public subnet.
   </details>

## Go deeper

- [VPC: how it works](https://docs.aws.amazon.com/vpc/latest/userguide/how-it-works.html): VPCs, subnets, routing, and gateways.
- [Compare security groups and network ACLs](https://docs.aws.amazon.com/vpc/latest/userguide/infrastructure-security.html): AWS's side-by-side.
