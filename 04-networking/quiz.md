# Module 4 quiz

Answer each question out loud or on paper *before* you open the answer. For the subnet questions, do the math by hand, then check it in Python.

1. How many addresses are in a `/26`? How many can you give to devices?
   <details><summary>Answer</summary>

   2^(32−26) = 64 addresses, 62 usable. The first is the network address and the last is the broadcast address.
   </details>

2. Are `192.168.10.100` and `192.168.10.140` in the same `/25`?
   <details><summary>Answer</summary>

   No. A `/25` splits a `/24` in half: `.0–.127` and `.128–.255`. They're on opposite sides.
   </details>

3. What do ports 22, 53, 80, and 443 carry? Which of them usually use UDP?
   <details><summary>Answer</summary>

   SSH, DNS, HTTP, HTTPS. DNS (53) usually uses UDP. The others use TCP.
   </details>

4. `ss -tlnp` shows `127.0.0.1:6379` and `0.0.0.0:22`. Which one can a machine on the network reach?
   <details><summary>Answer</summary>

   Only port 22. Port 6379 (Redis) is bound to loopback, so only programs on the same machine can reach it.
   </details>

5. `dig +short app.example.com` returns the right IP, but the browser goes somewhere else. Where do you look first?
   <details><summary>Answer</summary>

   The hosts file (`/etc/hosts` on Linux and Mac). Apps check it before DNS, and `dig` skips it.
   </details>

6. A web app returns `401`, `403`, `404`, and `503` to different users. Which ones mean the server itself is in trouble?
   <details><summary>Answer</summary>

   Only `503`. The 4xx codes mean the server answered and refused or couldn't find what was asked (not logged in, not allowed, no such page). 5xx means the server side failed.
   </details>

7. A developer says "the API keys are safe, they're base64-encoded in the config file." What do you say?
   <details><summary>Answer</summary>

   Base64 is encoding, not encryption. Anyone can decode it without a key. The keys need a secret store (you'll use one in Module 6), not a disguise.
   </details>

8. Why are passwords stored as slow, salted hashes instead of SHA-256 or encryption?
   <details><summary>Answer</summary>

   Hashes can't be reversed, unlike encryption. Salt makes each hash unique, so pre-computed tables don't work. Slow algorithms (yescrypt, bcrypt, scrypt, Argon2) make each guess expensive. SHA-256 is fast, so attackers can try billions of guesses per second.
   </details>

9. You connect to a server's port 8080. One time you get "connection refused," another time a timeout. What's different?
   <details><summary>Answer</summary>

   Refused: the server answered and nothing is listening on 8080. Timeout: nothing answered, which usually means a firewall dropped the traffic (or the host is down).
   </details>

10. A user says "the internet is down." Walk through your checks, in order.
    <details><summary>Answer</summary>

    First ask whether it's just them or everyone. Then: does the machine have an IP address (and not `169.254.x.x`)? A default gateway? Can it ping an IP on the internet, like `1.1.1.1`? Can it resolve a name with `dig`? Does the site answer `curl`? Stop and fix at the first failure.
    </details>

## Challenge

**Subnet drills, timed.** Write ten new questions like the ones in [lesson 2](02-subnets-and-cidr.md), with different numbers. Answer them all in under five minutes, then check each in Python. Repeat every few days until you get ten out of ten.

**"What happens when you type a URL into a browser and press Enter?"** Answer it out loud, in under two minutes, without notes. Cover DNS, the TCP handshake, TLS and the certificate, the HTTP request, and the status code. Record yourself on your phone and listen back. Then compare with the [mock interview answer](../appendix/mock-interviews.md#3-what-happens-when-you-type-a-url-into-a-browser-and-press-enter). This is one of the most common interview questions there is, for all three target roles.
