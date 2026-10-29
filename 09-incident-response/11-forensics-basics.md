# Forensics basics

**Pillars:** ☁️ Cloud · 🪪 Identity

## Why this matters

The first instinct with a hacked server is to fix it: reboot it, kill the strange process, delete the odd file. Every one of those destroys evidence. What was running, what it was connected to, what the attacker typed: much of it exists only in memory, and disappears when the machine stops.

**Forensics** is collecting evidence in a way that preserves it, and proving later that you didn't change it. You won't be a forensic investigator from this lesson. You'll learn the rules that keep you from destroying the evidence the investigator needs.

## The rules

**Order of volatility:** collect the evidence that disappears first, first.

| Order | Evidence | Gone when |
|---|---|---|
| 1 | Memory, running processes | The process ends or the machine stops |
| 2 | Network connections | They close (seconds to minutes) |
| 3 | Logged-in users, temp files | Logout, reboot |
| 4 | Disk | Overwritten, or the disk is deleted |
| 5 | Logs sent elsewhere (CloudTrail, flow logs) | Retention expires (days to years) |

**Chain of custody:** a record of who collected each piece of evidence, when, how, where it's stored, and its **hash**, so you can prove later it hasn't changed ([Module 4](../04-networking/07-crypto-basics.md)).

**In the cloud: snapshot first.** A disk **snapshot** captures the disk exactly as it was, in seconds, without touching the running server. Take it before you change anything.

## Do it

You'll triage your own lab server as if it were compromised.

1. **Start a chain-of-custody log.** Create `incidents/forensics-practice.md`:

   ```markdown
   # Evidence log: notes-lab (practice)

   | # | Time (UTC) | Collected by | What | How | Stored at | SHA-256 |
   |---|---|---|---|---|---|---|
   ```

2. **Snapshot the disk first**, before you log in:

   ```bash
   cd ~/my-security-portfolio/notes-app/infra
   INSTANCE=$(tofu output -raw lab_instance_id)
   VOLUME=$(aws ec2 describe-instances --instance-ids "$INSTANCE" --query 'Reservations[0].Instances[0].BlockDeviceMappings[0].Ebs.VolumeId' --output text)
   aws ec2 create-snapshot --volume-id "$VOLUME" --description "Forensic snapshot of $INSTANCE, practice" \
     --tag-specifications 'ResourceType=snapshot,Tags=[{Key=Purpose,Value=forensics-practice}]' --query SnapshotId --output text
   ```

   Log it. Your snapshot ID is now evidence #1.

   > **Cost:** snapshots bill by the gigabyte-month, a few cents for this disk. Delete it at the end of the lesson.

3. **Collect the volatile evidence, in order.** Connect with Session Manager ([Module 8](../08-security-concepts/07-closing-port-22.md)), and collect into one file with a timestamp on every section:

   ```bash
   aws ssm start-session --target "$INSTANCE"
   ```

   On the server:

   ```bash
   sudo -i
   OUT=/tmp/triage-$(hostname)-$(date -u +%Y%m%dT%H%M%SZ).txt
   {
     echo "== date";               date -u
     echo "== processes";          ps auxww
     echo "== network connections"; ss -tunap
     echo "== logged-in users";    who; last -n 20
     echo "== recent logins";      journalctl -u ssh -u 'snap.amazon-ssm-agent*' --since "-24h" --no-pager | tail -50
     echo "== cron jobs";          ls -la /etc/cron.* /var/spool/cron 2>/dev/null
     echo "== recently changed files in /etc, /tmp, /home"; find /etc /tmp /home -newermt "-24 hours" -type f 2>/dev/null
     echo "== sudo users";         getent group sudo
   } > "$OUT" 2>&1
   sha256sum "$OUT"
   ```

   Every section is something you learned to read in [Module 2](../02-linux/). Processes first (most volatile), then connections, then users, then disk. Note the hash.

4. **Get the file off the server.** Evidence left on a compromised machine can be changed by whoever controls it. At work, you'd copy it to a locked-down evidence bucket the server can't modify. Here, the simplest way is to print it and save it from your terminal.

   ```bash
   cat "$OUT"
   exit
   exit
   ```

   Copy the output from your terminal into `incidents/triage-output.txt` on your VM, then hash it there:

   ```bash
   sha256sum ~/my-security-portfolio/incidents/triage-output.txt
   ```

   If the two hashes match, the copy is exact. Log it as evidence #2, with both hashes.

5. **Read it like an investigator.** In `forensics-practice.md`, answer: Is any process unfamiliar? Any connection to an address that isn't AWS or Ubuntu's mirrors? Any user who shouldn't exist? Any file changed recently that you didn't change? On your clean lab server, the answer should be no to all. The practice is knowing **where** to look and what normal looks like.

6. **Clean up the snapshot:**

   ```bash
   aws ec2 delete-snapshot --snapshot-id snap-...
   ```

## Break it

Do it in the wrong order, on paper. An analyst sees a strange process on the server and immediately runs `sudo reboot` "to clear it." Then they take a snapshot and collect evidence.

For each row of the order-of-volatility table, write what was lost. The process (and what it was doing), its network connection (and where it was sending data), the attacker's session, anything in `/tmp` (cleared at boot on many systems). The snapshot only got the disk, after the attacker's tools were gone from memory. The reboot "fixed" the symptom and destroyed most of the answer.

The right first moves: **isolate, don't stop.** Snapshot the disk. Collect volatile evidence. Then contain it, by swapping its security group for one that allows nothing in or out, which cuts off the attacker without destroying anything. Write that order in your file.

## With Claude

Ask Claude Code:

```text
Read incidents/triage-output.txt. You're helping triage a possibly
compromised Ubuntu server. What's normal, what deserves a closer look, and
what would you collect next? Don't suggest anything that would change the
server.
```

**Check the work:** Claude is useful for "is this process normal on Ubuntu?" when you don't recognize something. For each item it flags, verify: look the process up (`man`, the package it came from with `dpkg -S`), and check whether the address it connected to is an AWS range. Did it suggest anything that **changes** the server (killing a process, deleting a file, updating packages)? Those destroy evidence, and you told it not to. Note the decision rule: AI can help **read** evidence; a human decides what to **do** to the system.

## Check yourself

1. Put these in collection order: disk, running processes, CloudTrail logs, network connections.
   <details><summary>Answer</summary>

   Running processes, network connections, disk, CloudTrail logs. Most volatile first.
   </details>

2. Why hash every piece of evidence?
   <details><summary>Answer</summary>

   So you can prove later that it hasn't changed since you collected it. The same hash, before and after, shows an exact copy.
   </details>

3. You find an attacker on a cloud server. Why change its security group instead of stopping it?
   <details><summary>Answer</summary>

   Swapping to a security group that allows no traffic cuts the attacker off while keeping memory, processes, and connections intact for evidence. Stopping it destroys them.
   </details>

## Go deeper

- [NIST SP 800-86: integrating forensic techniques into incident response](https://csrc.nist.gov/pubs/sp/800/86/final): the classic guide, including order of volatility.
- [AWS Security Incident Response Guide](https://docs.aws.amazon.com/security-ir/latest/userguide/introduction.html): how forensics works in AWS, including isolation and snapshots.
