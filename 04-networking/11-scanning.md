# Scanning your own network

## Why this matters

Attackers scan the whole internet, constantly, looking for open ports. A new server with SSH open usually gets its first login attempts within minutes. Defenders scan too, to find what's exposed before someone else does. "We didn't know that port was open" is a sentence in a lot of breach reports.

**nmap** is the standard scanner. It's the same tool on both sides. The only difference between you and an attacker is [permission](../00-start-here/02-ethics-and-the-law.md).

> **Re-read [the rules](../00-start-here/02-ethics-and-the-law.md) before you start.** You'll scan only your own VM and `scanme.nmap.org`, which the Nmap project explicitly allows you to scan lightly. Not your home router, not your employer's network, not your school's Wi-Fi, not a friend's site.

## Do it

1. Install nmap in your VM, and scan the VM itself:

   ```bash
   sudo apt install -y nmap
   nmap localhost
   ```

   Roughly:

   ```
   Starting Nmap 7.97 ( https://nmap.org ) at 2026-10-29 21:50 UTC
   Nmap scan report for localhost (127.0.0.1)
   Host is up (0.00010s latency).
   Not shown: 999 closed tcp ports (conn-refused)
   PORT   STATE SERVICE
   22/tcp open  ssh

   Nmap done: 1 IP address (1 host up) scanned in 0.05 seconds
   ```

   By default, nmap checks the 1,000 most common TCP ports. Compare it with `sudo ss -tlnp` from [lesson 3](03-tcp-udp-ports.md). The DNS service on port 53 doesn't show up, because it listens on `127.0.0.53`, not `127.0.0.1`. The scanner only sees what's listening on the address you scan.

2. Ask nmap what's actually running on each port, not just what usually runs there:

   ```bash
   nmap -sV localhost
   ```

   The `VERSION` column now shows something like `OpenSSH 10.0p2 Ubuntu`. That's what an attacker does next: find the version, then look up its known vulnerabilities. It's also why keeping packages updated ([Module 2](../02-linux/05-packages.md)) matters.

3. **Scan from the outside.** Inside the VM, traffic to `localhost` skips the firewall. To see what the network sees, scan from your laptop.

   **Mac:** install nmap with Homebrew, then scan your VM:

   ```bash
   brew install nmap
   nmap 192.168.64.5
   ```

   **Windows:** install nmap from [nmap.org/download](https://nmap.org/download.html) (free), and scan your forwarded ports: `nmap -p 2222,8080 127.0.0.1`.

   You should see SSH open, and everything else not reachable. That's your [firewall](08-firewalls.md) from the outside.

4. Scan the one internet host you're allowed to, lightly:

   ```bash
   nmap scanme.nmap.org
   ```

   Read the results like a defender: which ports are open, and does each one need to be?

5. Record what you found in `networking/scan-results.md`: each target, the open ports, and one sentence on whether each port should be open.

## Break it

Open a "forgotten" port, and find it. In one SSH session, start a listener on port 4444:

```bash
nc -l 4444
```

In another:

```bash
nmap -p 4444 localhost
```

```
PORT     STATE SERVICE
4444/tcp open  krb524
```

nmap calls it `krb524`, a Kerberos service. It isn't. It's your `nc`. Without `-sV`, the **SERVICE** column is just nmap's guess from the port number. Port 4444 is also a common default for attacker backdoors. A real port you don't recognize means: find the process with `sudo ss -tlnp`, then decide.

Now from your **laptop** (Mac): `nmap -p 4444 192.168.64.5`.

```
PORT     STATE    SERVICE
4444/tcp filtered krb524
```

**Filtered**: the firewall dropped the probe. Three states to know: **open** (something's listening), **closed** (the machine answered "nothing here," like "connection refused"), and **filtered** (no answer, usually a firewall, like a timeout). Stop the listener with `Ctrl+C`.

## With Claude

Paste your `nmap -sV localhost` output into [claude.ai](https://claude.ai) or Claude Code:

```text
This is an nmap scan of my own lab VM. What's exposed, and what would you
check or change to reduce what an attacker could find?
```

**Check the work:**

- Does every port Claude mentions actually appear in your scan?
- If it names a vulnerability for a specific version (like a CVE number for your OpenSSH version), look it up on the [NVD](https://nvd.nist.gov/) or [Ubuntu's CVE tracker](https://ubuntu.com/security/cves). AI often attaches real-looking CVE numbers to the wrong versions, and Ubuntu backports fixes without changing the version number.
- Did it suggest scanning anything other than your own machine? Ignore that. Permission doesn't come from an AI.

```bash
git add networking/scan-results.md
git commit -m "Add scan results"
git push
```

## Check yourself

1. What's the difference between `open`, `closed`, and `filtered` in nmap?
   <details><summary>Answer</summary>

   Open: something's listening. Closed: the host answered that nothing's there. Filtered: no answer, usually because a firewall dropped the probe.
   </details>

2. nmap says port 8080 is `http-proxy`. Is it?
   <details><summary>Answer</summary>

   Not necessarily. Without `-sV`, that's a guess from the port number. Run `nmap -sV`, or check `ss -tlnp` on the machine.
   </details>

3. A coworker wants to "quickly nmap" the office network to practice. What do you tell them?
   <details><summary>Answer</summary>

   Get written permission first from whoever owns the network. Without it, it's unauthorized scanning, whatever the intent. Practice on your own VM or `scanme.nmap.org`.
   </details>

## Go deeper

- [Nmap's official guide (free online)](https://nmap.org/book/toc.html): written by nmap's creator. The port scanning chapters explain exactly what each scan type sends.
