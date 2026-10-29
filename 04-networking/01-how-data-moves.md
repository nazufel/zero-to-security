# How data moves

## Why this matters

"The internet is down" is the most common ticket in IT, and it's almost never the whole internet. It's one broken piece: a cable, an address, a name lookup, a firewall rule. Networks are built in **layers**, and each layer fails in its own way. Once you know the layers, every network problem becomes a short list of questions you check in order.

## Do it

1. SSH into your VM and find its **IP address**, the number that identifies it on the network:

   ```bash
   ip -brief address
   ```

   ```
   lo               UNKNOWN        127.0.0.1/8 ::1/128
   enp0s1           UP             192.168.64.5/24 fdxx::xxxx/64
   ```

   Two **interfaces**, the network connections. `lo` is the **loopback**, which only talks to the machine itself (`127.0.0.1`, also called `localhost`). `enp0s1` (yours may be named differently) is the real network connection, with an IPv4 address like `192.168.64.5`. The `/24` is the subnet size, which is the next lesson.

2. Send a **packet**, a small chunk of data, to another machine and see if it answers:

   ```bash
   ping -c 3 1.1.1.1
   ```

   ```
   PING 1.1.1.1 (1.1.1.1) 56(84) bytes of data.
   64 bytes from 1.1.1.1: icmp_seq=1 ttl=57 time=12.4 ms
   64 bytes from 1.1.1.1: icmp_seq=2 ttl=57 time=11.9 ms
   64 bytes from 1.1.1.1: icmp_seq=3 ttl=57 time=12.1 ms

   --- 1.1.1.1 ping statistics ---
   3 packets transmitted, 3 received, 0% packet loss, time 2003ms
   ```

   `1.1.1.1` is a public DNS server run by Cloudflare. Three packets out, three back, about 12 milliseconds each way.

3. Now ping a **name** instead of a number:

   ```bash
   ping -c 3 example.com
   ```

   It works too, but notice the first line: `PING example.com (104.20.23.154)`. Before a single packet went out, your VM had to turn the name into an IP address. That's DNS (lesson 4), and it's a separate step that can fail on its own.

4. Learn the map. The **TCP/IP model** splits networking into four layers. You'll use it as a troubleshooting checklist, from the bottom up:

   | Layer | What it does | Example | How you test it |
   |---|---|---|---|
   | **4. Application** | The program's own conversation | HTTP, SSH, DNS | `curl`, `ssh`, `dig` |
   | **3. Transport** | Gets data to the right program, reliably or fast | TCP, UDP, ports | `ss`, `nc` (lesson 3) |
   | **2. Internet** | Gets packets between networks | IP addresses, routing | `ping`, `ip route` |
   | **1. Link** | Gets data across one cable or Wi-Fi hop | Ethernet, Wi-Fi | `ip link`, "is it plugged in?" |

   If layer 2 is broken, nothing above it can work. So you check from the bottom: is it connected, does it have an address, can it reach an IP, can it resolve a name, does the app answer?

   Start a notes file for this module in your portfolio, and copy this table into it:

   ```bash
   mkdir -p ~/my-security-portfolio/networking
   nano ~/my-security-portfolio/networking/network-notes.md
   ```

   You'll add to it all module, and commit it in the next lesson.

## Break it

Two failures that look the same to a user ("it doesn't work") but are completely different:

```bash
ping -c 3 not-a-real-site.invalid
```

```
ping: not-a-real-site.invalid: Name or service not known
```

```bash
ping -c 3 10.255.255.1
```

```
PING 10.255.255.1 (10.255.255.1) 56(84) bytes of data.

--- 10.255.255.1 ping statistics ---
3 packets transmitted, 0 received, 100% packet loss, time 2050ms
```

The first one failed at the **name**: no packet was ever sent, because there was no address to send it to. The second one had an address and sent packets, but nothing answered. Different layers, different fixes. When a user says "it doesn't work," your first job is to find out which of these it is.

## With Claude

Paste the output of `ip -brief address` and `ping -c 3 1.1.1.1` into [claude.ai](https://claude.ai) or Claude Code:

```text
I'm learning networking. Explain each part of this output, including ttl
and the /24. Which layer of the TCP/IP model is each piece about?
```

**Check the work:** Claude may describe the seven-layer **OSI model** instead of, or alongside, the four-layer TCP/IP model. Both are real; they're two ways to slice the same thing. Does its explanation match the table in this lesson? Ask it to map OSI's seven layers onto the four here. You'll hear "layer 7" and "layer 3" at work, so knowing both is useful.

## Check yourself

1. A user can `ping 1.1.1.1` but not `ping example.com`. Which layer or service is the problem?
   <details><summary>Answer</summary>

   Name resolution (DNS). The network works, since an IP is reachable, but names can't be turned into addresses.
   </details>

2. What's `127.0.0.1`?
   <details><summary>Answer</summary>

   The loopback address, `localhost`: the machine talking to itself. Traffic to it never leaves the machine.
   </details>

3. Why troubleshoot from the bottom layer up?
   <details><summary>Answer</summary>

   Each layer depends on the ones below it. There's no point debugging a website if the machine has no IP address.
   </details>

## Go deeper

- [Cloudflare Learning Center: what is the network layer?](https://www.cloudflare.com/learning/network-layer/what-is-the-network-layer/): clear, free explanations of every networking term in this module.
