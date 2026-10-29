# Troubleshooting

## Why this matters

"The internet is down" is the ticket you'll get more than any other. The person sending it is frustrated and wants it fixed now. What separates a good tech from a guesser is a **method**: the same short list of checks, in the same order, every time. Interviewers ask about it constantly, because the method is the skill.

## The method

Work up the layers from [lesson 1](01-how-data-moves.md), stopping at the first thing that fails:

| Step | Question | Command | If it fails |
|---|---|---|---|
| 1 | Do I have an address? | `ip -brief address` | Cable, Wi-Fi, DHCP ([lesson 5](05-dhcp-and-gateway.md)). `169.254.x.x` = no DHCP. |
| 2 | Do I have a way out? | `ip route` | No `default` line = no gateway |
| 3 | Can I reach the internet by IP? | `ping -c 2 1.1.1.1` | Gateway, upstream network, or a firewall |
| 4 | Can I resolve names? | `dig +short example.com` | DNS ([lesson 4](04-dns.md)). Check `/etc/hosts` too. |
| 5 | Does the service answer? | `curl -sI https://example.com` | The site, a firewall rule, or a certificate problem |

**Ask one scoping question first:** is it just this user, or everyone? If it's everyone, it's not their laptop. Check for an outage before you touch anything.

## Do it

1. Run each step by hand on your VM, and read each result before moving on.

2. When step 3 or 5 fails partway to a site, find **where** with `traceroute`, which lists every router a packet passes through:

   ```bash
   sudo apt install -y traceroute
   traceroute -n 1.1.1.1
   ```

   ```
    1  192.168.64.1  0.412 ms  0.301 ms  0.288 ms
    2  192.168.1.1   2.117 ms  1.980 ms  2.034 ms
    3  * * *
    4  10.20.30.1    9.882 ms  10.110 ms  9.954 ms
   ...
    9  1.1.1.1       12.302 ms  12.188 ms  12.240 ms
   ```

   Hop 1 is your VM's gateway (your laptop), hop 2 is probably your home router, and the rest are your internet provider and beyond. `* * *` means that router didn't reply. Many don't, and that's normal as long as later hops answer. If every hop after a certain point is `* * *`, that's where the trouble is.

3. Turn the method into a script, so you run it the same way every time. Create `netcheck.sh` in `~/my-security-portfolio/networking/`:

   ```bash
   #!/usr/bin/env bash
   # netcheck.sh: check the network from the bottom layer up, and stop at the first failure

   check() {
     local name="$1"
     shift
     if "$@" > /dev/null 2>&1; then
       echo "  OK    $name"
     else
       echo "  FAIL  $name"
       echo "Stop here: fix this layer before looking higher."
       exit 1
     fi
   }

   gateway=$(ip route | awk '/^default/ {print $3; exit}')

   echo "Checking the network, bottom layer up:"
   check "has an IPv4 address"        bash -c "ip -4 -brief address | grep -v '^lo' | grep -q UP"
   check "has a default gateway"      test -n "$gateway"
   check "reaches the internet by IP" ping -c 1 -W 2 1.1.1.1
   check "resolves names (DNS)"       dig +short +time=2 +tries=1 example.com
   check "web works (HTTPS)"          curl -sS --max-time 5 -o /dev/null https://example.com
   echo "All layers OK. If the user still has a problem, it's the app or the site."
   ```

   New pieces: `check() { ... }` is a Bash **function**. Inside it, `$1` is the first argument (the name), `shift` drops it, and `"$@"` is everything left, the command to run. `if command; then` asks "did that command succeed?", using the exit codes you learned in [Module 3](../03-python/10-argparse.md). `awk '{print $3}'` prints the third word of a line.

   ```bash
   chmod 755 netcheck.sh
   ./netcheck.sh
   ```

   ```
   Checking the network, bottom layer up:
     OK    has an IPv4 address
     OK    has a default gateway
     OK    reaches the internet by IP
     OK    resolves names (DNS)
     OK    web works (HTTPS)
   All layers OK. If the user still has a problem, it's the app or the site.
   ```

## Break it

Break DNS, and let the method find it. Point your VM's network interface at a DNS server that doesn't exist (`192.0.2.1` is a documentation address that never answers):

```bash
iface=$(ip route | awk '/^default/ {print $5; exit}')
sudo resolvectl dns "$iface" 192.0.2.1
sudo resolvectl flush-caches
./netcheck.sh
```

```
Checking the network, bottom layer up:
  OK    has an IPv4 address
  OK    has a default gateway
  OK    reaches the internet by IP
  FAIL  resolves names (DNS)
Stop here: fix this layer before looking higher.
```

To a user, this looks like "the internet is down." Every website fails. But the network is fine: `1.1.1.1` answers. The method found the layer in seconds, without a single guess. Fix it:

```bash
sudo resolvectl revert "$iface"
./netcheck.sh
```

All OK again. (If DNS is still failing, `sudo systemctl restart systemd-networkd` or a reboot will restore it.)

## With Claude

In Claude Code, in `~/my-security-portfolio/networking`:

```text
Read netcheck.sh. Add one more check between "has a default gateway" and
"reaches the internet by IP" that would catch a broken gateway. Explain
the change before you make it.
```

**Check the work:** read the diff, then test it **two** ways. Run it normally: does everything still pass? Then think about whether the new check could fail on a working network. Many gateways, including some VM setups, don't answer `ping`. If Claude added `ping $gateway`, does it pass on your VM? A check that fails on a healthy network is worse than no check, because it sends you to fix something that isn't broken. Did Claude mention that risk?

```bash
git add netcheck.sh
git commit -m "Add network troubleshooting script"
git push
```

## Check yourself

1. A user says "the internet is down." What's your first question?
   <details><summary>Answer</summary>

   Is it just you, or everyone? If it's everyone, check for an outage before touching their machine.
   </details>

2. `ping 1.1.1.1` works but every website fails. Where do you look?
   <details><summary>Answer</summary>

   DNS. The network is working by IP, so name resolution is the next layer up. Check `dig` and `/etc/hosts`.
   </details>

3. `traceroute` shows `* * *` at hop 3, but hops 4 through 9 answer. Is hop 3 the problem?
   <details><summary>Answer</summary>

   No. That router just doesn't reply to traceroute. Traffic is clearly getting past it, since later hops answer.
   </details>

## Go deeper

- The [mock interview](../appendix/mock-interviews.md) question "A user says the internet is down": practice answering it out loud now, using this method.
