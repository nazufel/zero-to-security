# Firewalls

**Pillars:** ☁️ Cloud

## Why this matters

A **firewall** decides which network traffic is allowed in or out. Every port listening on `0.0.0.0` is reachable by anything that can reach the machine, unless a firewall says otherwise. In the cloud, firewalls have new names (AWS calls them **security groups** and **network ACLs**), but the rules work the same way you'll learn here.

The rule of thumb is **default deny**: block everything, then allow only what you need. It's least privilege, for networks.

## Do it

1. Check the state of Ubuntu's firewall, `ufw` (Uncomplicated Firewall):

   ```bash
   sudo ufw status verbose
   ```

   If you ran the [Module 2 project](../02-linux/project.md) script on this VM, it's already active. If it says `Status: inactive`, continue.

2. **Take a snapshot.** Firewall mistakes lock you out.

3. Set the defaults, allow SSH **first**, then turn it on:

   ```bash
   sudo ufw default deny incoming
   sudo ufw default allow outgoing
   sudo ufw allow OpenSSH
   sudo ufw enable
   ```

   ```
   Command may disrupt existing ssh connections. Proceed with operation (y|n)? y
   Firewall is active and enabled on system startup
   ```

   ```bash
   sudo ufw status verbose
   ```

   ```
   Status: active
   Default: deny (incoming), allow (outgoing), deny (routed)

   To                         Action      From
   --                         ------      ----
   22/tcp (OpenSSH)           ALLOW IN    Anywhere
   22/tcp (OpenSSH (v6))      ALLOW IN    Anywhere (v6)
   ```

   Incoming: deny everything except SSH. Outgoing: allow, so updates and downloads still work.

4. Prove it blocks. Start the web server from [lesson 6](06-http.md):

   ```bash
   cd ~/web && python3 -m http.server 8080
   ```

   **From your laptop**, using your VM's address:

   ```bash
   curl --max-time 5 http://192.168.64.5:8080/
   ```

   ```
   curl: (28) Connection timed out after 5002 milliseconds
   ```

   A **timeout**, not "connection refused." The firewall silently dropped your packets, exactly like the mystery timeout in [lesson 3](03-tcp-udp-ports.md).

5. Allow it, but **only from your own network**, not the whole internet:

   ```bash
   sudo ufw allow from 192.168.64.0/24 to any port 8080 proto tcp
   ```

   (On VirtualBox, your subnet is `192.168.56.0/24`.) Try `curl` from your laptop again. It works. That rule reads exactly like an AWS security group rule: **source** CIDR, **port**, **protocol**.

6. List rules with numbers, and remove the one you just added:

   ```bash
   sudo ufw status numbered
   sudo ufw delete 3
   ```

   (Use whichever number your 8080 rule has.) Stop the web server with `Ctrl+C`. Leave the firewall on: deny by default, SSH allowed.

Add the `ufw` commands to your Linux cheat sheet.

## Break it

Lock yourself out on purpose. Keep your current SSH session open. Then remove the SSH rule:

```bash
sudo ufw delete allow OpenSSH
```

Your open session probably keeps working: the firewall still allows traffic for connections that already exist. Now, from a **second** laptop terminal:

```bash
ssh lab
```

```
ssh: connect to host 192.168.64.5 port 22: Operation timed out
```

You're locked out of new connections. On a cloud server with no console, that's a ticket to someone with more access than you, or a rebuild.

Fix it from the VM's own **console** (the UTM or VirtualBox window). It's the screen and keyboard attached to the machine, which the firewall doesn't touch. Log in there and run:

```bash
sudo ufw allow OpenSSH
```

Then `ssh lab` from your laptop works again.

**The rules:** allow SSH *before* enabling a firewall, keep a session open while you change rules, and know your way in that doesn't use the network. In AWS, that way in is SSM Session Manager (Module 8).

## With Claude

Ask Claude Code or [claude.ai](https://claude.ai):

```text
Write ufw rules for an Ubuntu web server. It should serve HTTPS to the
internet, allow SSH only from 203.0.113.0/24 (my office), and deny
everything else. Give me the commands in the order I should run them.
```

**Check the work:** before you run anything (on your VM, with a snapshot):

- Is SSH allowed **before** `ufw enable`? If not, that order locks you out.
- Is SSH limited to `203.0.113.0/24`, or did it also add `ufw allow OpenSSH` or `allow 22`, which opens it to everyone?
- Did it open port 80 too? Maybe that's fine (redirect to HTTPS), but you didn't ask for it. Every open port should be one you chose.
- Is incoming denied by default?

> **Careful on your VM:** your laptop isn't in `203.0.113.0/24`. If you run these rules exactly, you'll lock yourself out. Change the office range to your own subnet first. Noticing that is part of checking the work.

## Check yourself

1. What does "default deny" mean?
   <details><summary>Answer</summary>

   Everything is blocked unless a rule specifically allows it. It's least privilege for networks.
   </details>

2. Read this rule: `ufw allow from 10.0.1.0/24 to any port 5432 proto tcp`.
   <details><summary>Answer</summary>

   Allow TCP connections to port 5432 (PostgreSQL) from any address in `10.0.1.0/24`. Nothing else can reach that port.
   </details>

3. A connection to a port times out instead of being refused. What does that suggest?
   <details><summary>Answer</summary>

   A firewall is probably dropping the packets silently. "Refused" means the machine answered and nothing was listening.
   </details>

## Go deeper

- [Ubuntu: firewalls with ufw](https://documentation.ubuntu.com/server/how-to/security/firewalls/): the official guide, including rate limiting SSH with `ufw limit`.
