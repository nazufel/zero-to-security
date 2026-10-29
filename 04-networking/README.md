# Module 4: Networking

**Pillars:** ☁️ Cloud

> 🚧 **Outline.** Lessons are being written. The checklist and plan below are final.

## Why this module matters

Every attack and every outage travels over a network. "The internet is down" is the most common help desk ticket there is, and almost every security tool, from firewalls to cloud security groups, is a networking idea with a new name. Learn it here once and it pays off everywhere.

## You're ready to move on when…

- [ ] You can explain what an IP address, a subnet, and a default gateway are
- [ ] You can do CIDR math: how many addresses are in a `/24`, and whether two IPs share a subnet
- [ ] You can explain TCP vs. UDP, and name the ports for SSH, DNS, HTTP, and HTTPS
- [ ] You can explain what happens, step by step, when you type a URL into a browser
- [ ] You can look up DNS records with `dig` and troubleshoot a DNS problem
- [ ] You can read an HTTP request and response with `curl -v`
- [ ] You can explain what a certificate does and what a browser certificate warning means
- [ ] You can tell encoding, hashing, and encryption apart, and explain why passwords are hashed and salted
- [ ] You can write firewall rules that allow only what's needed
- [ ] You can capture and read traffic in Wireshark or `tcpdump`

## Lessons (planned)

1. **How data moves:** IP addresses, packets, the TCP/IP model as a troubleshooting map
2. **Subnets and CIDR:** drills until it's automatic
3. **TCP, UDP, and ports:** `ss` to see what's listening on your VM
4. **DNS:** the phone book of the internet, and the cause of an amazing number of outages. `dig`
5. **DHCP and the default gateway:** how a laptop joins a network
6. **HTTP and HTTPS:** `curl -v`, methods, status codes, headers
7. **Crypto basics:** encoding vs. hashing vs. encryption (base64 is not encryption), salted password hashes, certificates. *(OWASP A04: Cryptographic Failures)*
8. **Firewalls:** `ufw` on your VM. *Break it:* lock yourself out of SSH, then fix it from the console
9. **Seeing the traffic:** Wireshark and `tcpdump`; HTTP vs. HTTPS side by side
10. **Troubleshooting:** `ping`, `traceroute`, `dig`, `curl`, and a method that works for "the internet is down"
11. **Scanning your own network:** `nmap` against your VM only. Re-read [the rules](../00-start-here/02-ethics-and-the-law.md) first.

**With Claude:** have Claude explain a packet capture and design a subnet plan, then check its math by hand.

## Practice

- **Challenge:** subnetting drills; "what happens when you type a URL" in under two minutes, out loud
- **Project:** capture and annotate an HTTP and an HTTPS request in Wireshark; subnet a fictional office (staff, guests, servers) and write the firewall rules between them

## Dig Deeper

- Email security: SPF, DKIM, and DMARC (they're just DNS records)
- Symmetric vs. asymmetric encryption
