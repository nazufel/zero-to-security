# Module 5: Containers

**Pillars:** 🪪 Identity · 🤖 AI · ☁️ Cloud

> 🚧 **Outline.** Lessons are being written. The checklist and plan below are final.

## Why this module matters

A huge share of modern software runs in containers, so it's a huge share of what you'll defend. Containers are also a box: a second way, after the VM, to limit what code (and AI) can reach.

## Opinions

- **Docker Engine inside your Ubuntu VM**, not Docker Desktop. Free, open source, and it keeps everything in the sandbox.
- **[Chainguard's free container images](https://images.chainguard.dev/) are the default base image.** They're minimal, non-root by default, and free with no account. Every Dockerfile in this course starts from `cgr.dev/chainguard/...`.
- **[Grype](https://github.com/anchore/grype)** for scanning images (free, open source).
- **Pin by digest** (`@sha256:...`), not just by tag.

> **Last verified:** 2026-10-27. Chainguard's free images are public, need no login, and are tagged only `latest` and `latest-dev`. ([Chainguard Academy](https://edu.chainguard.dev/chainguard/containers/concepts/container-categories/))

## You're ready to move on when…

- [ ] You can run, list, stop, and remove containers, and read their logs
- [ ] You can map ports and mount volumes, and explain what each exposes
- [ ] You can write a Dockerfile and build an image from it
- [ ] You can write a multi-stage build: `-dev` image to build, minimal image to run
- [ ] You can explain why a minimal, non-root image is safer, and prove it with a scan
- [ ] You can pin an image by digest and explain why tags aren't enough
- [ ] You can verify an image's signature and download its SBOM with cosign
- [ ] You can review a Claude-written Dockerfile for root users, shells, and unpinned bases

## Lessons (planned)

1. **Why containers:** what they are, and how they differ from your VM
2. **Running containers:** `run`, `ps`, `logs`, `exec`, `stop`, `rm`
3. **Ports and volumes:** your networking skills, reused
4. **Your first Dockerfile:** containerize `logslayer` on the standard `python` image
5. **Switch to Chainguard:** a multi-stage build with `python:latest-dev` and `python:latest`
6. **Scan it:** Grype the standard image and the Chainguard image, and compare
7. **Pin by digest:** tags can move, digests can't
8. **Verify before you trust:** cosign signatures and SBOMs. *(OWASP A03: Software Supply Chain Failures, A08: Software or Data Integrity Failures)*

**Break it:** try `docker exec ... sh` on the Chainguard runtime image. It fails: there's no shell. If you can't get a shell, neither can an attacker.

**Case study:** in March 2026, attackers used stolen credentials to publish malicious releases of the Trivy security scanner and repoint its GitHub Actions tags to credential-stealing malware. The security tool itself was the attack path. Teams that pinned by commit SHA weren't affected; teams that trusted tags had to hunt through their logs. ([Wiz](https://www.wiz.io/blog/trivy-compromised-teampcp-supply-chain-attack))

## Practice

- **Project:** a hardened `logslayer` image in your portfolio: Chainguard base, multi-stage, non-root, pinned by digest, signature verified, with a README showing before/after scan results.

## Dig Deeper

- [Kubernetes](../dig-deeper/kubernetes/), using kind inside your VM
