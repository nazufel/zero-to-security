# Verify before you trust

**Pillars:** 🪪 Identity · ☁️ Cloud

## Why this matters

Pinning a digest proves you get the **same** image every time. It doesn't prove the image came from who you think, or what's inside it. Two more checks close that gap:

- A **signature** proves who built the image. Chainguard signs every image in its official build pipeline, and **cosign** checks the signature.
- An **SBOM** (Software Bill of Materials) lists every package inside. When the next big vulnerability is announced, an SBOM tells you in seconds whether you're affected.

Together, they're how you defend against **OWASP A03, Software Supply Chain Failures**, and **A08, Software or Data Integrity Failures**: trusting code you can't verify.

## Do it

1. Install **cosign** from its official releases, and check the download against the published checksum before you trust it:

   ```bash
   arch=$(dpkg --print-architecture)
   curl -fsSLO "https://github.com/sigstore/cosign/releases/latest/download/cosign-linux-${arch}"
   curl -fsSLO "https://github.com/sigstore/cosign/releases/latest/download/cosign_checksums.txt"
   grep " cosign-linux-${arch}$" cosign_checksums.txt | sha256sum -c
   ```

   ```
   cosign-linux-arm64: OK
   ```

   Only if it says `OK`:

   ```bash
   sudo install -m 755 "cosign-linux-${arch}" /usr/local/bin/cosign
   cosign version
   sudo apt install -y jq
   ```

   `jq` pretty-prints and filters JSON from the command line.

   > **Last verified:** 2026-10-29 with cosign 3.1 ([Chainguard docs](https://www.chainguard.dev/docs/chainguard/containers/security-and-compliance/verifying-chainguard-images-and-metadata-signatures-with-cosign)).

2. **Verify the signature** on the base image you build from:

   ```bash
   cosign verify \
     --certificate-oidc-issuer=https://token.actions.githubusercontent.com \
     --certificate-identity=https://github.com/chainguard-images/images/.github/workflows/release.yaml@refs/heads/main \
     cgr.dev/chainguard/python:latest > /dev/null
   ```

   `> /dev/null` hides the signature details (JSON). The result you care about is printed on its own:

   ```
   Verification for cgr.dev/chainguard/python:latest --
   The following checks were performed on each of these signatures:
     - The cosign claims were validated
     - Existence of the claims in the transparency log was verified offline
     - The code-signing certificate was verified using trusted certificate authority certificates
   ```

   Read the two flags as the question you're asking: "was this image signed by **Chainguard's release workflow on GitHub** (`--certificate-identity`), as proven by **GitHub's login system** (`--certificate-oidc-issuer`)?" There are no keys to manage. The signature is tied to an identity, and recorded in a public **transparency log** anyone can check. Identity again: it's the same idea as OIDC logins for pipelines in Module 8.

3. **Download the SBOM** and look inside:

   ```bash
   cosign download attestation \
     --predicate-type=https://spdx.dev/Document \
     --platform=linux/$(dpkg --print-architecture) \
     cgr.dev/chainguard/python:latest | jq -r .payload | base64 -d | jq .predicate > python-sbom.json

   jq -r '.packages[].name' python-sbom.json | sort | head -20
   jq '.packages | length' python-sbom.json
   ```

   A short list, a few dozen packages, compared with hundreds in the standard image. Notice `base64 -d` in the middle: the attestation is base64-encoded JSON. Encoding, not encryption ([Module 4](../04-networking/07-crypto-basics.md)).

4. **Use it** the way you would on the day a big vulnerability drops. Is `openssl` in this image, and which version?

   ```bash
   jq -r '.packages[] | select(.name | test("openssl")) | "\(.name) \(.versionInfo)"' python-sbom.json
   ```

   A few seconds instead of a day of asking around. When a critical OpenSSL CVE is announced, teams with SBOMs answer "are we affected?" before lunch.

5. Verify the **SBOM's** signature too, so you know nobody swapped it:

   ```bash
   cosign verify-attestation \
     --type https://spdx.dev/Document \
     --certificate-oidc-issuer=https://token.actions.githubusercontent.com \
     --certificate-identity=https://github.com/chainguard-images/images/.github/workflows/release.yaml@refs/heads/main \
     cgr.dev/chainguard/python:latest > /dev/null
   ```

   Look for the same "checks were performed" message.

## Break it

Ask cosign to verify the image came from someone else:

```bash
cosign verify \
  --certificate-oidc-issuer=https://token.actions.githubusercontent.com \
  --certificate-identity=https://github.com/attacker/images/.github/workflows/release.yaml@refs/heads/main \
  cgr.dev/chainguard/python:latest
```

```
Error: no matching signatures: none of the expected identities matched what was in the certificate
```

The image is signed, just not by that identity. This is why the `--certificate-identity` flag matters so much: "is it signed?" is the wrong question, because an attacker can sign their own malware. The right question is "is it signed **by the one identity I trust**?"

## With Claude

Ask Claude Code:

```text
Write a short Bash script, verify-base.sh, that verifies the signature on both
Chainguard base images in my Dockerfile before I build. It should stop with
an error if either check fails.
```

**Check the work:**

- Does it check `--certificate-identity` and `--certificate-oidc-issuer` exactly as in this lesson? Watch for `--certificate-identity-regexp '.*'` or similar, which accepts **any** signer and checks nothing useful.
- Does it read the image names from your `Dockerfile`, digests included, or use `:latest` and verify a different image than the one you build?
- Does it stop on failure (`set -e`, or checking exit codes)? Test that by breaking the identity on purpose, like the Break it step. A verification script that passes when verification fails is worse than none.

> **Free AI path:** do this with OpenCode; the prompt is the same.

```bash
git add verify-base.sh
git commit -m "Add base image signature check"
git push
```

## Check yourself

1. What does a signature prove that a digest doesn't?
   <details><summary>Answer</summary>

   Who built it. A digest proves you got the same bytes; a signature proves those bytes came from a specific identity you trust.
   </details>

2. Why is "the image is signed" not enough?
   <details><summary>Answer</summary>

   Anyone can sign anything, including malware. You have to check it's signed by the specific identity you expect.
   </details>

3. A critical vulnerability in a common library is announced. How does an SBOM help?
   <details><summary>Answer</summary>

   It lists every package and version in the image, so you can search it in seconds to see whether you're affected.
   </details>

## Go deeper

- [Sigstore documentation](https://docs.sigstore.dev/): how keyless signing, certificates, and the transparency log work.
- [OWASP A03:2025, Software Supply Chain Failures](https://owasp.org/Top10/2025/): the category and real examples.
