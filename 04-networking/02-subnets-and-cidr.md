# Subnets and CIDR

**Pillars:** ☁️ Cloud

## Why this matters

In Module 6 you'll build a network in AWS, and the first thing AWS asks is "what CIDR block?" Get it wrong and your subnets overlap, run out of addresses, or can't connect to each other, and you usually find out after you've built everything on top of them.

A **subnet** is a slice of a network's addresses. **CIDR** (Classless Inter-Domain Routing) is the notation for writing one: `192.168.64.0/24`. Security cares because subnets are how you separate things: staff from guests, databases from the internet.

## Do it

1. An IPv4 address is 32 **bits**, written as four numbers from 0 to 255:

   ```
   192   .  168   .   64    .   5
   8 bits   8 bits    8 bits    8 bits
   ```

   The number after the slash says how many bits, from the left, are the **network** part. The rest are for **hosts**, the individual machines.

   `192.168.64.0/24` means the first 24 bits (`192.168.64`) are the network, and the last 8 bits are for hosts: `192.168.64.0` to `192.168.64.255`.

2. The one formula you need: **a /N has 2^(32 − N) addresses.**

   | CIDR | Host bits | Addresses | Feels like |
   |---|---|---|---|
   | `/32` | 0 | 1 | One exact machine |
   | `/28` | 4 | 16 | A small group of servers |
   | `/26` | 6 | 64 | A small office floor |
   | `/24` | 8 | 256 | A typical home or office network |
   | `/20` | 12 | 4,096 | A large site |
   | `/16` | 16 | 65,536 | A whole cloud network (AWS VPC) |
   | `/0` | 32 | All of them | "Anywhere on the internet" |

   Each step smaller in the number **doubles** the size. A `/23` is two `/24`s. A `/25` is half a `/24`.

   Two addresses in every subnet are reserved: the first is the **network address** (`.0` in a `/24`) and the last is the **broadcast address** (`.255`). So a `/24` has 254 usable addresses. (AWS reserves 5 per subnet, not 2. You'll see that in Module 6.)

3. Memorize `/0`. You'll see `0.0.0.0/0` in every firewall and cloud security rule. It means **every IPv4 address there is**. "Allow port 22 from `0.0.0.0/0`" means "let the whole internet try to SSH in."

4. Are two IPs in the same subnet? For a `/24`, compare the first three numbers:

   - `192.168.64.5` and `192.168.64.200` in a `/24`: **same** (both `192.168.64`)
   - `192.168.64.5` and `192.168.65.5` in a `/24`: **different**

   For other sizes, work out the range first. A `/26` splits a `/24` into four blocks of 64: `.0–.63`, `.64–.127`, `.128–.191`, `.192–.255`. So `10.0.0.70/26` and `10.0.0.100/26` are both in `.64–.127`: same subnet.

5. Check your math with Python, which you know from Module 3:

   ```bash
   python3
   ```

   ```python
   >>> import ipaddress
   >>> net = ipaddress.ip_network("192.168.64.0/24")
   >>> net.num_addresses
   256
   >>> net.network_address, net.broadcast_address
   (IPv4Address('192.168.64.0'), IPv4Address('192.168.64.255'))
   >>> ipaddress.ip_address("192.168.64.200") in net
   True
   >>> ipaddress.ip_address("192.168.65.5") in net
   False
   >>> list(ipaddress.ip_network("10.0.0.0/24").subnets(new_prefix=26))
   [IPv4Network('10.0.0.0/26'), IPv4Network('10.0.0.64/26'), IPv4Network('10.0.0.128/26'), IPv4Network('10.0.0.192/26')]
   ```

6. **Drill.** Create `networking/subnet-drills.md` and answer these **by hand first**, then check each one in Python:

   ```markdown
   # Subnet drills

   | Question | My answer | Python says |
   |---|---|---|
   | How many addresses in a /27? |  |  |
   | How many usable addresses in a /24? |  |  |
   | First and last address of 10.1.4.0/22? |  |  |
   | Are 172.16.5.10 and 172.16.5.130 in the same /25? |  |  |
   | Split 10.0.0.0/24 into two equal subnets |  |  |
   | Smallest subnet that holds 50 hosts? |  |  |
   ```

   Repeat this with new numbers every few days until you can do it without thinking. It comes up in interviews, and in every cloud network you'll ever build.

## Break it

Ask Python for a network using a host's address instead of the network's:

```python
>>> ipaddress.ip_network("192.168.64.5/24")
Traceback (most recent call last):
  ...
ValueError: 192.168.64.5/24 has host bits set
```

`192.168.64.5` is a machine in the `192.168.64.0/24` network, not the network itself. Python is strict about the difference. Tools like AWS and firewalls will often just quietly round it for you, so `192.168.64.5/24` in a rule may mean the whole subnet, not one machine. If you meant one machine, write `/32`.

## With Claude

Ask [claude.ai](https://claude.ai) or Claude Code:

```text
Design a subnet plan for a small office using 10.20.0.0/22. I need separate
subnets for 60 staff devices, 30 guest devices, and 10 servers, with room to
grow. Show each subnet's CIDR, range, and usable host count.
```

**Check the work:** check **every** number in Python. AI is famously unreliable at this kind of arithmetic. Specifically:

- Is each subnet actually inside `10.20.0.0/22`?
- Do any two subnets overlap? (Python: `a.overlaps(b)`.)
- Does each one really fit its devices, counting the reserved addresses?

Log any math errors in your [AI check log](../01-ai-foundations/01-what-ai-is.md). You'll reuse this plan in the module project.

```bash
cd ~/my-security-portfolio
git add networking/
git commit -m "Add network notes and subnet drills"
git push
```

## Check yourself

1. How many addresses in a `/28`? How many usable?
   <details><summary>Answer</summary>

   2^(32−28) = 16 addresses, 14 usable (minus network and broadcast).
   </details>

2. A security rule allows SSH from `0.0.0.0/0`. What does that mean?
   <details><summary>Answer</summary>

   From any IPv4 address on the internet. It's one of the most common risky findings in cloud security reviews.
   </details>

3. Are `10.0.0.62` and `10.0.0.66` in the same `/26`?
   <details><summary>Answer</summary>

   No. A `/26` is blocks of 64: `.0–.63` and `.64–.127`. They're on either side of the boundary.
   </details>

## Go deeper

- [Subnetting practice](https://subnettingpractice.com/): free, randomized drills with instant answers.
