# Project: see the traffic, design the network

**Pillars:** ☁️ Cloud

## Why this matters

Two things in this project show up again and again in real jobs. One: proving, with a capture, what's actually on the wire, instead of arguing about it. Two: turning "keep the guests away from the servers" into subnets and firewall rules that do exactly that. In Module 6, you'll do the second one again in AWS, with VPCs and security groups. The thinking is identical.

## What to build

```text
my-security-portfolio/
└── networking/
    ├── README.md            # links to both parts, and what you learned
    ├── network-notes.md     # from the lessons
    ├── subnet-drills.md     # from lesson 2
    ├── netcheck.sh          # from lesson 10
    ├── scan-results.md      # from lesson 11
    ├── capture.md           # part 1
    └── network-design.md    # part 2
```

## Part 1: annotate HTTP vs. HTTPS

Use `http-vs-https.pcap` from [lesson 9](09-seeing-the-traffic.md). If you deleted it, capture it again.

In `capture.md`, for **each** of the two requests, write:

1. **The TCP handshake:** the three packets (SYN, SYN-ACK, ACK), with their source and destination IP and port.
2. **What an eavesdropper sees:** for HTTP, the method, path, headers, and the password, copied exactly. For HTTPS, what's visible (IPs, ports, the SNI name) and what isn't.
3. **How the connection ends:** find the FIN packets.

Add two Wireshark screenshots: the HTTP stream showing the password, and the TLS Client Hello showing the server name. Put them in `networking/images/` and link them from `capture.md`.

End with three sentences, in your own words, that you could say to a non-technical coworker who asks "why does HTTPS matter?"

## Part 2: design an office network

**The brief.** A small company is moving into a new office. You've been given `10.20.0.0/22`. They need:

| Group | Devices today | Notes |
|---|---|---|
| Staff | 60 | Laptops and phones. Growing fast. |
| Guests | 30 | Visitors' devices. Internet only. |
| Servers | 10 | Internal file server and an internal web app on HTTPS |
| IT admins | 4 | The only devices allowed to SSH into servers |

**Your job, in `network-design.md`:**

1. **Subnets.** A table with each group's CIDR, its first and last usable address, and its usable host count. Leave room to grow. **Check every number in Python** ([lesson 2](02-subnets-and-cidr.md)) and confirm none of them overlap:

   ```python
   >>> import ipaddress, itertools
   >>> nets = [ipaddress.ip_network(n) for n in ["...", "...", "...", "..."]]
   >>> all(n.subnet_of(ipaddress.ip_network("10.20.0.0/22")) for n in nets)
   True
   >>> any(a.overlaps(b) for a, b in itertools.combinations(nets, 2))
   False
   ```

2. **A diagram.** Boxes and arrows are fine, by hand, in any free drawing tool, or as text:

   ```text
   Internet ── Router/Firewall ──┬── Staff   10.20.?.?/?
                                 ├── Guests  10.20.?.?/?
                                 ├── Servers 10.20.?.?/?
                                 └── IT      10.20.?.?/?
   ```

3. **Firewall rules between the groups.** Default deny. One row per allowed path, with a reason. Then the rules for what's blocked, and why:

   ```markdown
   | From | To | Port/protocol | Action | Why |
   |---|---|---|---|---|
   | Staff | Servers | 443/tcp | Allow | Staff use the internal web app |
   |  |  |  |  |  |
   | Everything else | Anything | Any | Deny | Default deny |
   ```

   Every **allow** needs a reason. If you can't say why it's there, delete it.

4. **The rules on one server.** Write the `ufw` commands for the internal web server, in the right order ([lesson 8](08-firewalls.md)): HTTPS from staff only, SSH from IT only, everything else denied.

<details><summary>One good answer (open it after you've done yours)</summary>

**Subnets**

| Group | CIDR | Usable range | Usable hosts |
|---|---|---|---|
| Staff | `10.20.0.0/24` | 10.20.0.1 – 10.20.0.254 | 254 |
| Guests | `10.20.1.0/25` | 10.20.1.1 – 10.20.1.126 | 126 |
| Servers | `10.20.2.0/26` | 10.20.2.1 – 10.20.2.62 | 62 |
| IT admins | `10.20.2.64/28` | 10.20.2.65 – 10.20.2.78 | 14 |
| *(free for growth)* | `10.20.1.128/25`, `10.20.2.80` – `10.20.3.255` | | |

Staff gets a whole `/24` because it's growing fast and the space is there. IT gets its own small subnet so "only IT can SSH" is one rule about one CIDR, not a list of individual addresses.

**Firewall rules**

| From | To | Port/protocol | Action | Why |
|---|---|---|---|---|
| Staff | Servers | 443/tcp | Allow | Internal web app |
| Staff | Servers | 445/tcp | Allow | File server (SMB) |
| IT admins | Servers | 22/tcp | Allow | Server administration |
| Staff, IT | Internet | 80, 443/tcp; 53/udp | Allow | Web and DNS |
| Guests | Internet | 80, 443/tcp; 53/udp | Allow | Internet only |
| Guests | Staff, Servers, IT | Any | Deny | Guests are untrusted |
| Servers | Staff, Guests | Any (new connections) | Deny | Servers answer; they don't start conversations with laptops |
| Internet | Anything inside | Any (new connections) | Deny | Nothing internal is public |
| Everything else | Anything | Any | Deny | Default deny |

**On the web server**

```bash
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow from 10.20.2.64/28 to any port 22 proto tcp
sudo ufw allow from 10.20.0.0/24 to any port 443 proto tcp
sudo ufw enable
```

SSH is allowed before `enable`, and only from IT's subnet. Yours can differ. What matters is that every number checks out and every allow has a reason.
</details>

## With Claude

Give Claude the same brief, word for word, and ask for its subnets and firewall rules. Then review its answer like a senior engineer reviewing a junior's:

- [ ] Every subnet is inside `10.20.0.0/22`, and none overlap (check in Python)
- [ ] Each subnet really holds its devices, counting the reserved addresses
- [ ] Nothing allows `0.0.0.0/0` inbound to anything inside
- [ ] Guests can't reach staff, servers, or IT
- [ ] SSH to servers is limited to IT
- [ ] The `ufw` commands allow SSH before `enable`
- [ ] Every allow has a reason

Add a section to `network-design.md` called **"Claude's design vs. mine"**: where it was better, where it was wrong, and which of its mistakes would have caused a real problem.

## Finish

Write `networking/README.md` linking both parts, with three or four sentences on what you learned. Add it to your portfolio's main README table, then:

```bash
cd ~/my-security-portfolio
git add networking/
git commit -m "Add networking project: capture analysis and office network design"
git push
```

## Done when

- [ ] `capture.md` explains both captures, with two screenshots
- [ ] `network-design.md` has subnets that pass the Python checks, a diagram, and rules where every allow has a reason
- [ ] Claude's design is reviewed against the checklist
- [ ] You can explain, out loud, why guests can't reach the file server, pointing to the exact rule that stops them
