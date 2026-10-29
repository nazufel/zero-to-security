# Closing port 22

**Pillars:** 🪪 Identity · ☁️ Cloud

## Why this matters

In [Module 6](../06-cloud-aws/05-compute.md) you opened SSH to the internet for half an hour and strangers showed up within minutes. Even restricted to your IP, port 22 is a door: it needs a key that can be stolen, a rule that has to be updated every time your IP changes, and a server that has to be patched against every SSH bug.

**SSM Session Manager** gives you a shell on the server with **no open inbound ports at all**. The server's agent connects **out** to AWS, and you connect through AWS, authenticated with IAM. No keys to manage, every session logged, and nothing for scanners to find.

## Do it

1. **Let the server talk to Session Manager.** In `instance_profile.tf`, add:

   ```hcl
   resource "aws_iam_role_policy_attachment" "lab_ssm" {
     role       = aws_iam_role.lab.name
     policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
   }
   ```

   Ubuntu's AWS images already run the SSM agent. It just needs permission.

2. **Install the Session Manager plugin** in your VM, so the AWS CLI can open sessions:

   ```bash
   case "$(dpkg --print-architecture)" in arm64) p=ubuntu_arm64 ;; *) p=ubuntu_64bit ;; esac
   curl -fsSL "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/$p/session-manager-plugin.deb" -o ssm-plugin.deb
   sudo apt install -y ./ssm-plugin.deb && rm ssm-plugin.deb
   session-manager-plugin --version
   ```

   > **Last verified:** 2026-10-29 ([Session Manager plugin install](https://docs.aws.amazon.com/systems-manager/latest/userguide/install-plugin-debian-and-ubuntu.html)).

3. Apply, wait a minute for the agent to check in, then connect:

   ```bash
   tofu apply
   aws ssm describe-instance-information --query 'InstanceInformationList[].[InstanceId,PingStatus]' --output table
   aws ssm start-session --target "$(aws ec2 describe-instances --filters Name=tag:Name,Values=notes-lab Name=instance-state-name,Values=running --query 'Reservations[0].Instances[0].InstanceId' --output text)"
   ```

   You're in, as `ssm-user`. Run `sudo -i` if you need root. Type `exit` to leave.

4. **Now close the door.** Everything SSH-related comes out:

   - In `ec2.tf`: delete the `aws_key_pair` resource and the `key_name` line. Rename the security group to `lab`, change its description to `"No inbound at all: admin access is through SSM Session Manager"`, and delete its `ingress` block entirely. Update `vpc_security_group_ids` to `[aws_security_group.lab.id]`.
   - In `vpc.tf`: delete the NACL's SSH rule (rule 100). Keep the ephemeral-port rule: the agent's outbound HTTPS connections need their replies.
   - In `variables.tf`: delete `my_ip` and `ssh_public_key_path`. Delete `terraform.tfvars`.
   - In `outputs.tf`: replace `lab_ip` with:

     ```hcl
     output "lab_instance_id" {
       value = aws_instance.lab.id
     }
     ```

   ```bash
   tofu apply
   aws ssm start-session --target "$(tofu output -raw lab_instance_id)"
   ```

   Still works. Zero inbound rules.

5. **See who connected.** Every session is a CloudTrail event:

   ```bash
   aws cloudtrail lookup-events --lookup-attributes AttributeKey=EventName,AttributeValue=StartSession --max-results 5 \
     --query 'Events[].[EventTime,Username]' --output table
   ```

   Compare with SSH, where the server's own `auth.log` was the only record, on the very machine an attacker would want to clean up.

6. Delete the old key, and commit:

   ```bash
   rm ~/.ssh/aws_lab ~/.ssh/aws_lab.pub
   git add -A .
   git commit -m "Close port 22: admin access through SSM Session Manager"
   git push
   ```

   Update your secrets inventory from lesson 6: one row gone.

## Break it

Try the old way:

```bash
nc -zv -w 5 "$(aws ec2 describe-instances --instance-ids "$(tofu output -raw lab_instance_id)" --query 'Reservations[0].Instances[0].PublicIpAddress' --output text)" 22
```

```
nc: connect to ... port 22 (tcp) timed out: Operation now in progress
```

A timeout: nothing answers, because nothing is allowed in ([Module 4](../04-networking/03-tcp-udp-ports.md)). Scan it with `nmap` from your VM if you like (it's your own server): every port filtered. To the internet, there's nothing here to attack.

Now try Session Manager as an identity that shouldn't get a shell, Claude's view-only role:

```bash
aws ssm start-session --target "$(tofu output -raw lab_instance_id)" --profile claude
```

`AccessDeniedException`. Shell access is now an **IAM permission** (`ssm:StartSession`), which you can grant per person, per server, require MFA for, and audit. A firewall rule could only ever say "this IP address."

## With Claude

Ask Claude Code:

```text
Write an IAM policy that lets the notes-developers group start Session
Manager sessions only on instances tagged Name = notes-lab, and only if they
signed in with MFA. Then explain how I'd test it with the policy simulator.
```

**Check the work:** `ssm:StartSession` needs two resources: the instance (with a tag condition like `ssm:resourceTag/Name`) **and** the session document (`arn:aws:ssm:*:*:document/SSM-SessionManagerRunShell`). Did Claude include both? Is the MFA condition the right key (`aws:MultiFactorAuthPresent`)? Did it allow `ssm:*` "for simplicity"? Test it with `simulate-custom-policy`, using `--context-entries` for the tag and MFA, as in [Module 7](../07-identity/05-evaluation-logic.md).

## Check yourself

1. How does Session Manager work without any inbound port?
   <details><summary>Answer</summary>

   The SSM agent on the server connects outbound to AWS. You connect to AWS too, and AWS relays the session. Nothing ever connects in to the server.
   </details>

2. What controls who can open a session?
   <details><summary>Answer</summary>

   IAM: the `ssm:StartSession` permission, which can be limited by instance, tag, and conditions like MFA.
   </details>

3. Where is a Session Manager connection recorded?
   <details><summary>Answer</summary>

   In CloudTrail (`StartSession`, with who and when), outside the server, where an attacker on the server can't delete it.
   </details>

## Go deeper

- [AWS Systems Manager Session Manager](https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager.html): including session logging to S3 and CloudWatch.
