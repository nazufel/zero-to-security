# TCP, UDP, and ports

## Why this matters

An IP address gets a packet to the right machine. A **port** gets it to the right program on that machine. Port 22 is the SSH server, port 443 is the web server. Every port that's listening is a door someone can knock on, and attackers scan the internet for open doors all day.

When you read an alert, a firewall rule, or a cloud security group, it's always an address and a port. You need to read both at a glance.

## Do it

1. Learn the ports you'll see every day:

   | Port | Protocol | Service | Uses |
   |---|---|---|---|
   | 22 | TCP | SSH | Remote login |
   | 53 | UDP (and TCP) | DNS | Name lookups |
   | 80 | TCP | HTTP | Unencrypted web |
   | 443 | TCP | HTTPS | Encrypted web |
   | 3389 | TCP | RDP | Windows remote desktop. A favorite attacker target. |

   Add them to your `network-notes.md`. Check any port you don't recognize in the system's own list:

   ```bash
   grep -w 443 /etc/services
   ```

2. Know the two ways to send data:

   | | **TCP** | **UDP** |
   |---|---|---|
   | Setup | A three-step **handshake** first: SYN, SYN-ACK, ACK | None. Just sends. |
   | Delivery | Guaranteed, in order, resent if lost | Best effort. Lost packets stay lost. |
   | Speed | Slower | Faster |
   | Used by | Web, SSH, email: anything that can't lose data | DNS lookups, video calls, games |

3. See what's listening on your VM:

   ```bash
   sudo ss -tulnp
   ```

   Roughly:

   ```
   Netid State  Recv-Q Send-Q  Local Address:Port  Peer Address:Port Process
   udp   UNCONN 0      0       127.0.0.53%lo:53         0.0.0.0:*     users:(("systemd-resolve",...))
   tcp   LISTEN 0      4096    127.0.0.53%lo:53         0.0.0.0:*     users:(("systemd-resolve",...))
   tcp   LISTEN 0      4096          0.0.0.0:22         0.0.0.0:*     users:(("sshd",...))
   ```

   `-t` TCP, `-u` UDP, `-l` listening, `-n` numbers not names, `-p` which program. You used this in [Module 2](../02-linux/06-services.md). Now read the **local address** column:

   - `0.0.0.0:22` means "port 22 on **every** interface": reachable from the network.
   - `127.0.0.53:53` means "only on loopback": only this machine can reach it.

   Same port number, completely different exposure. This is one of the first things to check on any server.

4. Open a port yourself, and talk to it. In one SSH session:

   ```bash
   nc -l 9000
   ```

   `nc` (netcat) is now listening on TCP port 9000. In a **second** SSH session:

   ```bash
   sudo ss -tlnp | grep 9000
   nc localhost 9000
   ```

   Type `hello` and press Enter. It appears in the first window. You just made a TCP connection by hand. Press `Ctrl+C` in both.

## Break it

Knock on a door that isn't there:

```bash
nc -zv localhost 9001
```

```
nc: connect to localhost (127.0.0.1) port 9001 (tcp) failed: Connection refused
```

**Connection refused** means the machine answered and said "nothing's listening here." That's fast and clear.

Now try a port on a machine that doesn't answer at all:

```bash
nc -zv -w 5 10.255.255.1 22
```

```
nc: connect to 10.255.255.1 port 22 (tcp) timed out: Operation now in progress
```

A **timeout** means nothing answered. Either nothing's there, or a **firewall** silently dropped your packets. Refused versus timed out is one of the most useful clues in troubleshooting. You'll see it again in lesson 8, when you build a firewall that does the dropping.

## With Claude

Paste your `sudo ss -tulnp` output into [claude.ai](https://claude.ai) or Claude Code:

```text
This is everything listening on my Ubuntu VM. For each line, tell me the
program, whether it's reachable from the network or only locally, and
whether a learning VM needs it.
```

**Check the work:** for each claim about "reachable from the network," check the local address yourself: `0.0.0.0` or a real IP means network, `127.x` means local only. Did Claude get any of them backwards? Did it identify the program from the `Process` column, or guess from the port number? A program can listen on any port it likes, so the port number alone proves nothing.

## Check yourself

1. Which ports are SSH, DNS, HTTP, and HTTPS?
   <details><summary>Answer</summary>

   22, 53, 80, and 443.
   </details>

2. A database shows as listening on `127.0.0.1:5432`. Can someone on the internet connect to it?
   <details><summary>Answer</summary>

   No. It's bound to loopback, so only programs on the same machine can reach it. On `0.0.0.0:5432`, it would be reachable from the network.
   </details>

3. You try to connect to a server's port 443. You get "connection refused" on one server and a timeout on another. What does each tell you?
   <details><summary>Answer</summary>

   Refused: the server is up, but nothing listens on 443. Timeout: nothing answered, so the server may be down, or a firewall is dropping the traffic.
   </details>

## Go deeper

- [Cloudflare: what is a computer port?](https://www.cloudflare.com/learning/network-layer/what-is-a-computer-port/): ports, TCP, and UDP explained.
