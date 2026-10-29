# DHCP and the default gateway

## Why this matters

When you open your laptop in a coffee shop, it gets an IP address, a way out to the internet, and a DNS server, all in a second, without you typing anything. **DHCP** (Dynamic Host Configuration Protocol) does that. When it fails, you get one of the most common help desk tickets: "I'm connected to Wi-Fi, but there's no internet."

It's also a security story. Whoever answers DHCP tells your laptop where to send all its traffic and which DNS server to trust. A fake DHCP server on a network can quietly route everyone through an attacker.

## Do it

1. Your VM got its address from DHCP when it booted. Find the conversation in the logs:

   ```bash
   sudo journalctl -b | grep -i dhcp
   ```

   Look for a line like:

   ```
   enp0s1: DHCPv4 address 192.168.64.5/24, gateway 192.168.64.1 acquired from 192.168.64.1
   ```

   That one line holds three of the four things DHCP hands out: an **address**, a **subnet** (`/24`), and a **gateway**. The fourth, DNS servers, you saw with `resolvectl status` in [lesson 4](04-dns.md).

   DHCP is a four-step exchange, easy to remember as **DORA**: the client broadcasts a **D**iscover ("anyone out there?"), a server sends an **O**ffer ("you can have .5"), the client sends a **R**equest ("I'll take .5"), and the server **A**cknowledges it.

2. Find your **default gateway**, the router your VM sends anything that isn't on its own subnet to:

   ```bash
   ip route
   ```

   ```
   default via 192.168.64.1 dev enp0s1 proto dhcp src 192.168.64.5 metric 100
   192.168.64.0/24 dev enp0s1 proto kernel scope link src 192.168.64.5
   ```

   Read it as two rules:

   - Anything in `192.168.64.0/24` is **local**: send it straight there.
   - Anything else (**default**) goes **via** `192.168.64.1`, the gateway.

   That's how [subnets](02-subnets-and-cidr.md) decide where a packet goes.

3. Look at your **laptop's** DHCP lease too.

   **Mac:**

   ```bash
   ipconfig getpacket en0
   ```

   Look for `yiaddr` (your address), `router`, `domain_name_server`, and `lease_time`. (If `en0` shows nothing, your Wi-Fi may be `en1`.)

   **Windows (PowerShell):**

   ```powershell
   ipconfig /all
   ```

   Look for `IPv4 Address`, `Default Gateway`, `DHCP Server`, `DNS Servers`, and `Lease Obtained`.

   Add your laptop's address, gateway, and DNS server to your `network-notes.md`. Is the DHCP server the same machine as the gateway? At home, it usually is: your router does both.

4. Learn the sign that DHCP failed. If a laptop asks for an address and nobody answers, it gives itself one in `169.254.0.0/16`. A help desk tech who sees `169.254.x.x` knows immediately: **this machine never heard from DHCP.** Check the cable, the Wi-Fi, or the DHCP server, not the website.

## Break it

**Take a snapshot first.** Then delete your VM's default gateway:

```bash
sudo ip route del default
ip route
```

Only the local route is left. Now:

```bash
ping -c 2 1.1.1.1
```

```
ping: connect: Network is unreachable
```

The internet is gone. But your SSH session is still working. Why? Your laptop is on the VM's **local** subnet, so that traffic never needed the gateway. "Local things work, the internet doesn't" points straight at the gateway. That's the kind of clue that turns a vague ticket into a two-minute fix.

Put it back by re-applying the network configuration:

```bash
sudo netplan apply
ip route
ping -c 2 1.1.1.1
```

(If that doesn't bring the `default` route back, `sudo reboot` will.)

## With Claude

Paste your `ip route` output (from before you broke it) into [claude.ai](https://claude.ai) or Claude Code:

```text
Explain each line of this routing table. If I ping 192.168.64.20, 8.8.8.8,
and 10.0.0.5, which route does each packet use, and why?
```

**Check the work:** work it out yourself first, using the subnet rule: is the destination inside `192.168.64.0/24`? Then compare. `10.0.0.5` is a **private** address, but it isn't in your subnet, so it goes to the gateway like any internet address. "Private" doesn't mean "local." Did Claude get that right?

## Check yourself

1. A user's laptop has the address `169.254.12.34`. What's wrong?
   <details><summary>Answer</summary>

   It never got an address from DHCP, so it assigned itself one. Check the connection and the DHCP server.
   </details>

2. What four things does DHCP usually hand out?
   <details><summary>Answer</summary>

   An IP address, a subnet mask, a default gateway, and DNS servers.
   </details>

3. A server can reach other machines on its subnet but nothing on the internet. What's the first thing you check?
   <details><summary>Answer</summary>

   Its default gateway: `ip route` should show a `default via` line, and the gateway should answer a ping.
   </details>

## Go deeper

- [Cloudflare: what is DHCP?](https://www.cloudflare.com/learning/network-layer/what-is-dhcp/): DORA, leases, and DHCP security.
