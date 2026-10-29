# Logs and pipes

## Why this matters

When something goes wrong on a server, the evidence is in the logs. As a SOC analyst, reading logs is most of the job. As a help desk tech, "can you check the logs?" will be your first question to every engineer.

Any internet-facing SSH server gets password-guessing attempts within minutes of going online. In this lesson you'll attack your own VM, then find yourself in the logs.

## Do it

1. Make some evidence. **On your laptop**, try to SSH into the VM as a user that doesn't exist, three times, with any wrong password:

   ```bash
   ssh hacker@192.168.64.5
   ```

   (Windows: `ssh -p 2222 hacker@127.0.0.1`.) Press `Ctrl+C` after the third `Permission denied`.

2. **In the VM**, ask the system journal what the SSH service saw:

   ```bash
   sudo journalctl -u ssh --since "10 minutes ago" --no-pager
   ```

   Somewhere in the output:

   ```
   Invalid user hacker from 192.168.64.1 port 51234
   Failed password for invalid user hacker from 192.168.64.1 port 51234 ssh2
   ```

   That's you, the attacker, with your IP address. (On VirtualBox, it shows as `10.0.2.2`, the address of the port forward.) The **journal** is where Ubuntu's services write their logs, and `journalctl` reads it.

3. The same events in the classic log file. Check it exists:

   ```bash
   ls -l /var/log/auth.log
   ```

   If you get `No such file or directory`, install the service that writes it: `sudo apt install -y rsyslog`, then repeat step 1. You'll want this file: `logslayer`, the tool you build in Module 3, reads it.

4. Find just the failures with `grep`, which prints only the lines that match:

   ```bash
   sudo grep "Failed password" /var/log/auth.log
   ```

5. Now **pipes**. The `|` sends one command's output into the next command. Count the failures:

   ```bash
   sudo grep "Failed password" /var/log/auth.log | wc -l
   ```

   ```
   3
   ```

6. Build a real investigation, one pipe at a time. Run each line, and watch what each new step adds:

   ```bash
   sudo grep "Failed password" /var/log/auth.log
   sudo grep "Failed password" /var/log/auth.log | grep -oE "from [0-9.]+"
   sudo grep "Failed password" /var/log/auth.log | grep -oE "from [0-9.]+" | sort
   sudo grep "Failed password" /var/log/auth.log | grep -oE "from [0-9.]+" | sort | uniq -c
   sudo grep "Failed password" /var/log/auth.log | grep -oE "from [0-9.]+" | sort | uniq -c | sort -rn
   ```

   What you should see at the end:

   ```
         3 from 192.168.64.1
   ```

   Failed logins, counted per IP address, worst first. On a real internet-facing server, this list can run to hundreds of IPs. Each pipe does one small job. Together they answer a real question. (`grep -oE` prints only the part that matches a pattern. [Regex](../dig-deeper/) is the pattern language, in Dig Deeper.)

7. Now the question that actually matters. Did any login **succeed**?

   ```bash
   sudo grep "Accepted" /var/log/auth.log
   ```

   You'll see your own real logins. In an investigation, a success from an IP that was just failing is the line that turns "noise" into an incident.

8. Watch logs live. Run this in the VM, then fail a login from your laptop again:

   ```bash
   sudo tail -f /var/log/auth.log
   ```

   The failure appears as it happens. `Ctrl+C` to stop.

Add `journalctl -u`, `grep`, `|`, `wc -l`, `sort | uniq -c`, and `tail -f` to your cheat sheet.

## Break it

Search without `sudo`:

```bash
grep "Failed password" /var/log/auth.log
```

```
grep: /var/log/auth.log: Permission denied
```

Logs are protected because they're full of usernames, IP addresses, and sometimes worse. Check who can read them:

```bash
ls -l /var/log/auth.log
```

```
-rw-r----- 1 syslog adm 41210 Mar 14 02:31 /var/log/auth.log
```

Owner `syslog`, group `adm`. Remember that contractor from lesson 7?

Now a mistake that hides evidence: search for the wrong case.

```bash
sudo grep "failed password" /var/log/auth.log | wc -l
```

```
0
```

Zero, because `grep` is case-sensitive and the log says `Failed`. A tired analyst at 3 a.m. concludes "no failed logins." Use `grep -i` when you're not sure of the exact text, and never trust a zero you didn't double-check.

## With Claude

Copy your last ~20 lines of `auth.log` (`sudo tail -20 /var/log/auth.log`). Before pasting, think about [what never goes in](../01-ai-foundations/04-what-never-goes-in.md): this is your own lab VM, so it's fine. A real company's logs would not be.

```text
I'm learning SOC work. Here are lines from /var/log/auth.log on my lab VM.
Tell me what happened, in order, and whether anything looks like an attack.
```

**Check the work:** check every claim against the raw lines. Did Claude get the count of failures right? Did it get the IP right? Did it say a login succeeded when none did, or miss one that did? Count it yourself with your pipeline from step 6. AI summarizing logs is genuinely useful, and it's also exactly where a confident miscount sends an investigation the wrong way.

```bash
cd ~/my-security-portfolio
git add linux/linux-cheatsheet.md
git commit -m "Add log commands to cheat sheet"
git push
```

## Check yourself

1. What does `|` do?
   <details><summary>Answer</summary>

   It sends the output of the command on the left into the command on the right, so small commands can be chained into an answer.
   </details>

2. You see 5,000 failed SSH logins from one IP. What's the next thing you search for?
   <details><summary>Answer</summary>

   A successful login (`Accepted`) from that IP, or for that user. Failures are noise; a success means someone got in.
   </details>

3. `grep "error" app.log | wc -l` prints `0`. Are there no errors?
   <details><summary>Answer</summary>

   Not necessarily. `grep` is case-sensitive, so `Error` and `ERROR` wouldn't match. Try `grep -i`.
   </details>

## Go deeper

- [OverTheWire Bandit](https://overthewire.org/wargames/bandit/): this module's challenge. Many early levels are exactly this: find the needle with `find`, `grep`, and pipes.
