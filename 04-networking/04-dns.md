# DNS

## Why this matters

On October 4, 2021, Facebook, Instagram, and WhatsApp vanished from the internet for about six hours. A configuration change cut off Facebook's DNS servers from the rest of the internet, so nobody could look up their addresses. The servers were fine. Nobody could find them. Engineers reportedly had trouble getting into the buildings to fix it, because the badge system depended on the same network.

**DNS** (Domain Name System) turns names like `example.com` into IP addresses. It's the internet's phone book, and when it breaks, everything looks broken. There's a saying in operations: *it's always DNS.*

## Do it

1. Install `dig`, the standard DNS lookup tool:

   ```bash
   sudo apt install -y dnsutils
   ```

2. Look up a name:

   ```bash
   dig example.com
   ```

   Find the **ANSWER SECTION**:

   ```
   ;; ANSWER SECTION:
   example.com.        182    IN    A    104.20.23.154
   example.com.        182    IN    A    172.66.147.243
   ```

   Your addresses may differ. Read each column: the **name**, the **TTL** (seconds this answer can be cached), the class (`IN`, internet), the **record type** (`A`), and the **value**, an IPv4 address. Two A records means two servers can answer.

3. Get just the answer, and try other record types:

   ```bash
   dig +short example.com
   dig +short example.com AAAA
   dig +short google.com MX
   dig +short google.com TXT
   dig +short example.com NS
   ```

   | Type | What it holds | Example |
   |---|---|---|
   | **A** | An IPv4 address | `104.20.23.154` |
   | **AAAA** | An IPv6 address | `2606:4700:10::6814:179a` |
   | **CNAME** | "This name is really that name" | `www.github.com` → `github.com` |
   | **MX** | Which servers receive email for the domain | `10 smtp.google.com.` |
   | **TXT** | Free text, often for email security and ownership checks | `"v=spf1 include:_spf.google.com ~all"` |
   | **NS** | Which DNS servers are in charge of the domain | `hera.ns.cloudflare.com.` |

   That `v=spf1` TXT record is email security: it lists which servers may send email as `google.com`. You'll find more in [Dig Deeper](../dig-deeper/).

4. Ask a specific DNS server instead of your default one:

   ```bash
   dig @1.1.1.1 +short example.com
   ```

   If your normal DNS gives a different answer from `1.1.1.1`, something between you and the internet is changing answers. Sometimes that's on purpose (a company filtering malware sites). Sometimes it's an attacker.

5. See what your VM uses for DNS:

   ```bash
   resolvectl status
   ```

   Look for `DNS Servers`. Your VM asks those servers, usually your home router or the VM software, which ask the internet.

Add the record type table to your `network-notes.md`.

## Break it

Lie to your own machine. Before asking DNS, Linux checks a local file, `/etc/hosts`. Back it up, then point `example.com` somewhere else:

```bash
sudo cp /etc/hosts /etc/hosts.bak
echo "127.0.0.1 example.com" | sudo tee -a /etc/hosts
ping -c 1 example.com
curl -sS --max-time 5 http://example.com
```

```
PING example.com (127.0.0.1) 56(84) bytes of data.
curl: (7) Failed to connect to example.com port 80 after 0 ms: Couldn't connect to server
```

`example.com` now "lives" on your own machine, where nothing's listening on port 80. And `dig` still gives the real answer, because `dig` asks DNS servers directly and skips `/etc/hosts`:

```bash
dig +short example.com
```

So `dig` says one thing and your apps do another. That's a classic troubleshooting trap. It's also a classic malware trick: edit the hosts file so the bank's website, or the antivirus update server, points somewhere else. When names go to the wrong place, check `/etc/hosts`.

Put it back:

```bash
sudo cp /etc/hosts.bak /etc/hosts
ping -c 1 example.com
```

## With Claude

Ask [claude.ai](https://claude.ai) or Claude Code:

```text
What DNS records does github.com have? List the A, MX, NS, and TXT records.
```

**Check the work:** run `dig +short github.com A`, `MX`, `NS`, and `TXT` yourself, and compare. Unless Claude actually looked them up, it answered from training data, which may be out of date or invented. DNS changes all the time. **For live facts about the network, the tool is the source of truth, not the AI.** Note what it got wrong in your [AI check log](../01-ai-foundations/01-what-ai-is.md).

```bash
cd ~/my-security-portfolio
git add networking/network-notes.md
git commit -m "Add DNS notes"
git push
```

## Check yourself

1. Which record type tells you where a domain's email goes?
   <details><summary>Answer</summary>

   MX.
   </details>

2. `dig example.com` gives the right IP, but `curl example.com` connects somewhere else. Where do you look?
   <details><summary>Answer</summary>

   `/etc/hosts`. Apps check it before DNS; `dig` skips it.
   </details>

3. What does a TTL of 300 mean on a DNS record?
   <details><summary>Answer</summary>

   Resolvers can cache that answer for 300 seconds (5 minutes). After a DNS change, some users may see the old answer until it expires.
   </details>

## Go deeper

- [Cloudflare: what is DNS?](https://www.cloudflare.com/learning/dns/what-is-dns/): how a lookup travels from your laptop to the servers in charge of a domain.
- [Meta's write-up of the October 2021 outage](https://engineering.fb.com/2021/10/05/networking-traffic/outage-details/): the real postmortem, in their words.
