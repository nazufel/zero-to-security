# Module 5: Containers

**Pillars:** 🪪 Identity · 🤖 AI · ☁️ Cloud

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

## Lessons

1. [Why containers](01-why-containers.md): what they are, how they differ from your VM, and why the `docker` group is root
2. [Running containers](02-running-containers.md): `run`, `ps`, `logs`, `exec`, `stop`, `rm`
3. [Ports and volumes](03-ports-and-volumes.md): your networking skills, reused, and how Docker goes around ufw
4. [Your first Dockerfile](04-first-dockerfile.md): containerize `logslayer` on the standard `python` image
5. [Switch to Chainguard](05-switch-to-chainguard.md): a multi-stage build with `python:latest-dev` and `python:latest`. *Break it:* try to get a shell. There isn't one. If you can't get a shell, neither can an attacker.
6. [Scan it](06-scan-it.md): Grype the standard image and the Chainguard image, and compare
7. [Pin by digest](07-pin-by-digest.md): tags can move, digests can't. With the Trivy case study.
8. [Verify before you trust](08-verify-before-you-trust.md): cosign signatures and SBOMs. *(OWASP A03: Software Supply Chain Failures, A08: Software or Data Integrity Failures)*

**Case study:** in March 2026, attackers used stolen credentials to publish malicious releases of the Trivy security scanner and repoint its GitHub Actions tags to credential-stealing malware. The security tool itself was the attack path. Teams that pinned by commit SHA weren't affected; teams that trusted tags had to hunt through their logs. ([Wiz](https://www.wiz.io/blog/trivy-compromised-teampcp-supply-chain-attack))

## Practice

- [Quiz](quiz.md)
- [Project: a hardened `logslayer` image](project.md): Chainguard base, multi-stage, non-root, pinned by digest, signature verified, with a README showing before/after scan results

## Dig Deeper

- [Kubernetes](../dig-deeper/kubernetes/), using kind inside your VM
