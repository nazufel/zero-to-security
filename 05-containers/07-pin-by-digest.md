# Pin by digest

**Pillars:** 🪪 Identity · 🤖 AI

## Why this matters

In March 2026, attackers used stolen credentials to publish malicious releases of **Trivy**, a popular open-source security scanner, and to repoint its GitHub Actions tags to credential-stealing malware. Teams whose pipelines said "use the Trivy action at this tag" got the malware automatically, the next time their pipeline ran. The security tool itself was the attack path. Teams that **pinned by commit SHA** weren't affected; teams that trusted tags had to hunt through their logs. ([Wiz](https://www.wiz.io/blog/trivy-compromised-teampcp-supply-chain-attack))

A **tag** like `latest` or `3.14` is a label someone can move to point at different content. A **digest** like `sha256:b21d…` is a hash of the content itself ([Module 4](../04-networking/07-crypto-basics.md)). It can't be moved. If the content changes, the digest changes.

## Do it

1. Find the digest of the image you build from:

   ```bash
   sudo docker buildx imagetools inspect cgr.dev/chainguard/python:latest
   ```

   Near the top:

   ```
   Name:      cgr.dev/chainguard/python:latest
   MediaType: application/vnd.oci.image.index.v1+json
   Digest:    sha256:b21d678dcbec131cb15da75685598924a498a865f07331ff55135b34632822e6
   ```

   Yours will be different; Chainguard rebuilds `latest` often. Below that, it lists a separate digest per platform (`linux/amd64`, `linux/arm64`). Use the top-level **index** digest: it works on any platform.

2. Get the digest for `latest-dev` the same way:

   ```bash
   sudo docker buildx imagetools inspect cgr.dev/chainguard/python:latest-dev
   ```

3. Pin both in your `Dockerfile`. Keep the tag for humans to read; Docker uses the digest:

   ```dockerfile
   FROM cgr.dev/chainguard/python:latest-dev@sha256:<your latest-dev digest> AS build
   ...
   FROM cgr.dev/chainguard/python:latest@sha256:<your latest digest>
   ```

   **Get both digests on the same day.** The build stage and the run stage must have the same Python version, or the virtual environment you copy won't run.

4. Rebuild and check it still works:

   ```bash
   sudo docker build -t logslayer:chainguard .
   sudo docker run --rm -v "$PWD/samples:/logs:ro" logslayer:chainguard /logs/auth.log
   ```

   Now every build uses exactly the same base image, until **you** decide to change it.

5. Understand the trade-off. A pinned image never gets fixes on its own. Pinning means updating **on purpose**: every week or so, look up the new digests, rebuild, rescan ([lesson 6](06-scan-it.md)), test, and commit. In Module 8, a bot will open that pull request for you. Pinning without updating just freezes your vulnerabilities in place.

## Break it

Watch a tag move. Tag your standard image as if it were a release of some tool:

```bash
sudo docker tag logslayer:standard mytool:1.0
sudo docker image inspect --format '{{.Id}}' mytool:1.0
```

Now "publish" different content under the same tag:

```bash
sudo docker tag logslayer:chainguard mytool:1.0
sudo docker image inspect --format '{{.Id}}' mytool:1.0
```

Same name, `mytool:1.0`. Different ID: completely different content. Anyone who runs `mytool:1.0` tomorrow gets whatever it points to tomorrow, with no warning. That's all an attacker with publish access has to do, and it's exactly what happened with Trivy.

A digest can't do that. Ask for `sha256:b21d…` and you get those exact bytes, or nothing.

```bash
sudo docker rmi mytool:1.0
```

## With Claude

Ask Claude Code:

```text
Pin the base images in my Dockerfile by digest. Use the current digests for
cgr.dev/chainguard/python:latest-dev and cgr.dev/chainguard/python:latest.
```

**Check the work:** this is a trap for AI. It can't know today's digest from memory, so unless it ran a command to look it up, any digest it wrote is invented or out of date. Compare every digest it wrote with your `imagetools inspect` output. A made-up digest fails the build, which is the safe failure. A real but **old** digest builds fine and quietly ships an out-of-date base. If Claude did run the commands, check that it used the top-level index digest and took both on the same run.

> **Free AI path:** do this with OpenCode; the prompt is the same.

```bash
git add Dockerfile
git commit -m "Pin Chainguard base images by digest"
git push
```

## Check yourself

1. What's the difference between a tag and a digest?
   <details><summary>Answer</summary>

   A tag is a movable label. A digest is a hash of the content, so it always refers to exactly the same image.
   </details>

2. If you pin by digest, do you still get security fixes?
   <details><summary>Answer</summary>

   Not automatically. You get them when you update the digest on purpose, then rebuild, rescan, and test.
   </details>

3. How did pinning protect some teams in the Trivy compromise?
   <details><summary>Answer</summary>

   Attackers moved tags to point at malware. Teams pinned to a commit SHA kept running the exact, known-good version.
   </details>

## Go deeper

- [Docker: image digests](https://docs.docker.com/reference/cli/docker/image/pull/#pull-an-image-by-digest-immutable-identifier): pulling and referencing images by digest.
