# Network evidence: VPC Flow Logs

**Pillars:** ☁️ Cloud

## Why this matters

CloudTrail tells you who called the AWS API. It says nothing about **network traffic**: which machines talked to which, on which ports, and whether the firewall let them. When an investigation asks "did the compromised server connect anywhere it shouldn't?" or "how much data left the network, and to where?", the answer is in **VPC Flow Logs**.

Flow logs record **metadata**, not content: who, to whom, which port, how many bytes, and ACCEPT or REJECT. It's the cloud version of the packet capture you made in [Module 4](../04-networking/09-seeing-the-traffic.md), with the payloads left out.

## Do it

1. **Turn them on.** Add the flow log section of [`logging.tf`](../06-cloud-aws/reference/notes-app/infra/logging.tf) (the log group, its role, and `aws_flow_log.lab`), and apply. It records `ALL` traffic, accepted and rejected, for the lab VPC.

2. **Read one record.** Wait about 15 minutes, then:

   ```bash
   aws logs filter-log-events --log-group-name /aws/vpc/notes-flow --limit 5 --query 'events[].message' --output text
   ```

   ```
   2 123456789012 eni-0abc123 198.51.100.200 10.0.1.25 51234 23 6 1 40 1793314083 1793314140 REJECT OK
   ```

   The default fields, in order:

   | Field | Example | Means |
   |---|---|---|
   | version, account, interface | `2 123456789012 eni-0abc123` | Which network card |
   | source, destination | `198.51.100.200 10.0.1.25` | Who talked to whom |
   | source port, destination port | `51234 23` | Port 23 is Telnet: someone knocking |
   | protocol | `6` | TCP (17 is UDP) |
   | packets, bytes | `1 40` | How much |
   | start, end | `1793314083 1793314140` | When (Unix time) |
   | action | `REJECT` | Your security group and NACL said no |

3. **See the internet knocking.** Your lab server has **no** inbound rules ([Module 8](../08-security-concepts/07-closing-port-22.md)), so every connection attempt from outside is rejected, and recorded. Count them by destination port:

   ```bash
   aws logs filter-log-events --log-group-name /aws/vpc/notes-flow --filter-pattern REJECT \
     --query 'events[].message' --output text | tr '\t' '\n' | awk '{print $7}' | sort | uniq -c | sort -rn | head
   ```

   Roughly:

   ```
        41 22
        17 23
        12 3389
         9 445
         6 80
   ```

   SSH, Telnet, Remote Desktop, Windows file sharing: the internet's constant background scan, which you first met in [Module 6](../06-cloud-aws/05-compute.md). All of it rejected. Now count by **source** (`$4`) to see who's knocking most.

4. **See the server's own traffic.** Find what the lab server sent **out** and was allowed:

   ```bash
   aws logs filter-log-events --log-group-name /aws/vpc/notes-flow --filter-pattern ACCEPT \
     --query 'events[].message' --output text | tr '\t' '\n' | awk '$4 ~ /^10\.0\./ {print $5, $7}' | sort | uniq -c | sort -rn | head
   ```

   Mostly port 443 (Session Manager, AWS APIs) and 80 (Ubuntu updates), exactly what its security group allows. In an investigation, an outbound connection to an unfamiliar address on an odd port is where you'd start pulling the thread.

5. Commit, and save your two queries in `incidents/queries.md`. You'll reuse them.

## Break it

Find the limits of flow logs. Open a session on the lab server and download something:

```bash
aws ssm start-session --target "$(tofu output -raw lab_instance_id)"
curl -s https://example.com -o /dev/null
exit
```

Wait 15 minutes and find that connection in the flow logs. You'll see the server's IP talking to an address on port 443, with a byte count. You **won't** see that it was `example.com`, what URL, or what came back. Flow logs have no names and no content. To answer "what did it download?", you'd need DNS logs, a proxy, or the server itself (lesson 11).

Write in `queries.md` what flow logs can and can't answer. Knowing what your evidence **can't** tell you keeps you from overclaiming in an incident report.

## With Claude

Export a sample of your flow logs and ask Claude Code to analyze them:

```bash
aws logs filter-log-events --log-group-name /aws/vpc/notes-flow --limit 200 --query 'events[].message' --output text \
  | tr '\t' '\n' > ~/flow-sample.txt
```

```text
Read ~/flow-sample.txt (VPC flow logs, default format). Summarize: the top
source IPs and ports for rejected traffic, all accepted outbound
destinations, and anything that looks suspicious. Show the commands you'd
use to verify each claim.
```

**Check the work:** run its verification commands yourself. Does each count match? Did it get the field order right? (A common mistake is swapping source and destination ports.) Did it call something suspicious that's normal, like the server's own 443 traffic to AWS? Did it identify a scanner by **company name** from an IP alone? That's a guess, unless it shows how. `rm ~/flow-sample.txt` when done.

## Check yourself

1. What do flow logs record, and what don't they?
   <details><summary>Answer</summary>

   Connection metadata: source and destination addresses and ports, protocol, bytes, packets, times, and ACCEPT or REJECT. Not domain names or content.
   </details>

2. A flow log line ends in `REJECT`. What rejected it?
   <details><summary>Answer</summary>

   A security group or network ACL. The packet never reached the application.
   </details>

3. How would you check whether a compromised server sent data out?
   <details><summary>Answer</summary>

   Filter flow logs for ACCEPT records with that server as the source, and look for unusual destinations, ports, or large byte counts.
   </details>

## Go deeper

- [VPC Flow Log records](https://docs.aws.amazon.com/vpc/latest/userguide/flow-log-records.html): every field, and custom formats with more.
