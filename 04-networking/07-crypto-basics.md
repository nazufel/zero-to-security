# Crypto basics

**Pillars:** 🪪 Identity

## Why this matters

In 2012, LinkedIn was breached and about 6.5 million password hashes were posted online. They were hashed with SHA-1 and **no salt**, so most were cracked within days. Four years later, the full set turned out to be about 117 million accounts. People who reused their LinkedIn password elsewhere had those accounts taken over too.

**OWASP A04, Cryptographic Failures**, is about mistakes like that: using the wrong tool, or using the right one wrong. The first step is knowing three tools that people constantly mix up: encoding, hashing, and encryption.

## The three tools

| | **Encoding** | **Hashing** | **Encryption** |
|---|---|---|---|
| Purpose | Change the format | Make a fingerprint | Keep a secret |
| Reversible? | Yes, by **anyone** | **No**, by design | Yes, but only with the **key** |
| Needs a key? | No | No | Yes |
| Example | base64 | SHA-256 | AES |
| Use it for | Sending data safely through systems | Passwords, checking files haven't changed | Secrets you need to read again |

## Do it

1. **Encoding** isn't security. You proved that in [Module 1](../01-ai-foundations/04-what-never-goes-in.md). One more time, both ways:

   ```bash
   echo -n 'hunter2' | base64
   echo 'aHVudGVyMg==' | base64 -d
   ```

   ```
   aHVudGVyMg==
   hunter2
   ```

   No key. Anyone can reverse it.

2. **Hashing** makes a fixed-size fingerprint. Change one character and the whole fingerprint changes:

   ```bash
   echo -n 'hunter2' | sha256sum
   echo -n 'hunter3' | sha256sum
   ```

   ```
   f52fbd32b2b3b86ff88ef6c490628285f482af15ddcb29541f94bcf526a3f6c7  -
   fb8c2e2b85ca81eb4350199faddd983cb26af3064614e737ea9f479621cfa57a  -
   ```

   There's no "un-hash." That's why systems store a **hash** of your password, not the password: when you log in, they hash what you typed and compare. A thief who steals the hashes doesn't get the passwords directly.

   Hashes also prove a file hasn't changed. Download pages for Ubuntu, and other software, publish a SHA-256 next to each file. Run `sha256sum` on what you downloaded and compare. You'll use this idea for container images in Module 5.

3. So why were LinkedIn's hashes cracked? Because the same password always gives the same hash. Attackers pre-compute hashes for millions of common passwords and just look them up. **Salt** fixes that: a random value added to each password before hashing, stored alongside the hash.

   ```bash
   openssl passwd -6 -salt Xy7Kq2 hunter2
   openssl passwd -6 -salt Pb3Mn9 hunter2
   ```

   ```
   $6$Xy7Kq2$1ejYI105Wex6rzLLFVLVEj3zLsWxrlDzkS9vuaSkNz8Sx1i8NgMncpkqmQVOnlauo3zGVKTbfM5oVygli77/71
   $6$Pb3Mn9$3oZQNATbr6UDDa0MinmOcZV80z8hxxjjag5LWbIKXGW.eMraROO2mUXH1ndj/xsoY7G.VQSanij9XW6MXxtfP0
   ```

   Same password, completely different hashes. A pre-computed table is useless, and two users with the same password don't reveal each other. The format is `$algorithm$salt$hash`.

4. Look at your own password in [`/etc/shadow`](../02-linux/04-permissions.md) again:

   ```bash
   sudo grep "^$USER:" /etc/shadow
   ```

   It starts with `$y$`. That's **yescrypt**, a password hash designed to be **slow**, so each guess costs an attacker real time. Fast hashes like SHA-256 are great for checking files and terrible for passwords, because an attacker can try billions of guesses per second. Passwords get slow, salted hashes: yescrypt, bcrypt, scrypt, or Argon2.

5. **Encryption** is reversible, but only with the key. Encrypt a file with a passphrase:

   ```bash
   echo 'Pay Jordan $500' > note.txt
   openssl enc -aes-256-cbc -pbkdf2 -salt -in note.txt -out note.enc
   xxd note.enc | head -2
   ```

   Enter a passphrase twice. The output is unreadable bytes (it starts with the word `Salted__`; encryption uses salt too). Now decrypt it:

   ```bash
   openssl enc -d -aes-256-cbc -pbkdf2 -in note.enc
   ```

   With the right passphrase, you get the note back. With the wrong one:

   ```
   bad decrypt
   ```

   That's the deal: whoever has the key can read it, and nobody else can. The hard part of encryption is almost never the math. It's protecting the key. (Module 8 uses AWS KMS for exactly that.)

6. **Certificates** are how HTTPS knows it's talking to the real site. Look at one:

   ```bash
   echo | openssl s_client -connect example.com:443 -servername example.com 2>/dev/null | openssl x509 -noout -subject -issuer -dates
   ```

   ```
   subject=CN=example.com
   issuer=C=US, O=SSL Corporation, CN=Cloudflare TLS Issuing ECC CA 3
   notBefore=Sep 26 22:49:11 2026 GMT
   notAfter=Dec 25 22:56:35 2026 GMT
   ```

   - **subject:** who this certificate is for.
   - **issuer:** the **certificate authority** (CA) that vouches for it. Your system trusts a built-in list of CAs.
   - **dates:** it's only valid between these. Certificates expire on purpose.

   When a browser shows a **certificate warning**, one of these failed: the name doesn't match, the issuer isn't trusted, or the dates are wrong. The warning means "I can't prove this is the real site." Clicking through it means trusting a connection that might be an attacker in the middle.

Clean up: `rm note.txt note.enc`.

## Break it

See why unsalted, fast hashes are broken. Hash the world's most common password with MD5, an old, fast hash:

```bash
echo -n 'password' | md5sum
```

```
5f4dcc3b5aa765d61d8327deb882cf99  -
```

Copy that hash into any search engine. The first results tell you what it is. You didn't crack anything: someone already did, and the answer is public, because an unsalted hash of the same password is the same everywhere.

Then see the two certificate failures you'll meet most:

```bash
curl https://expired.badssl.com/
curl https://wrong.host.badssl.com/
```

```
curl: (60) SSL certificate problem: certificate has expired
curl: (60) SSL: no alternative certificate subject name matches target host name 'wrong.host.badssl.com'
```

Expired, and issued for a different name. [badssl.com](https://badssl.com/) exists so you can practice this safely.

## With Claude

In Claude Code or [claude.ai](https://claude.ai):

```text
Write a short Python function to store user passwords for my app's login system.
```

**Check the work:** this is a classic place for AI to get it wrong. Look at what it used:

- `hashlib.md5` or `hashlib.sha256` on the password? **Wrong:** fast hashes, as you just saw.
- No salt, or the same salt for every user? **Wrong.**
- `base64`, or encryption with a key in the code? **Wrong:** reversible.
- A slow, salted password hash, like `hashlib.scrypt` with `os.urandom` for the salt, or the `bcrypt` or `argon2` packages? **Right.**

If it got it wrong, tell it why, and log it in your [AI check log](../01-ai-foundations/01-what-ai-is.md). Then ask it the honest follow-up: should you be writing password storage yourself at all? (Usually not. Use a framework's built-in login, or an identity provider. Module 7.)

## Check yourself

1. Which is base64: encoding, hashing, or encryption? Is it safe for storing a secret?
   <details><summary>Answer</summary>

   Encoding. No: anyone can decode it, no key needed.
   </details>

2. Why hash passwords instead of encrypting them?
   <details><summary>Answer</summary>

   A hash can't be reversed, so even the system storing it can't recover the password. Encryption can be reversed by anyone who gets the key, and the key has to be stored somewhere.
   </details>

3. What does a salt protect against?
   <details><summary>Answer</summary>

   Pre-computed lookup tables, and spotting users with the same password. Each user's hash is different even when the password isn't.
   </details>

4. A browser warns that a site's certificate is "issued to a different name." What might be happening?
   <details><summary>Answer</summary>

   A misconfiguration, or an attacker in the middle presenting their own certificate. Either way, you can't trust the connection, so don't enter anything into it.
   </details>

## Go deeper

- [OWASP A04:2025, Cryptographic Failures](https://owasp.org/Top10/2025/): the category, with real examples.
- [OWASP Password Storage Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Password_Storage_Cheat_Sheet.html): exactly how passwords should be stored, from the people who keep the Top 10.
