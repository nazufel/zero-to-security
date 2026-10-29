# Project: a hardened `logslayer` image

**Pillars:** 🪪 Identity · 🤖 AI · ☁️ Cloud

## Why this matters

"I containerized an app" is common on a resume. "I cut my image's known vulnerabilities from hundreds to zero, here's the scan, and here's how I verify every base image before I build" is not. This project turns the module into that proof, with numbers you measured yourself.

## What to build

By the end, `logslayer/` in your portfolio has:

```text
logslayer/
├── .dockerignore
├── Dockerfile            # Chainguard, multi-stage, pinned by digest
├── Dockerfile.standard   # the "before," kept for comparison
├── verify-base.sh        # signature check for both base images
└── README.md             # with a container section: before/after results
```

The image must be:

- [ ] **Chainguard base**, built in two stages (`latest-dev` to build, `latest` to run)
- [ ] **Non-root** (check with `docker inspect`)
- [ ] **No shell** in the final image (prove it with `docker run --entrypoint sh`)
- [ ] **Pinned by digest**, both stages, taken on the same day
- [ ] **Signature verified** before building, by `verify-base.sh`
- [ ] **Scanned**, with the results in the README

## Steps

1. **Rebuild both images fresh**, so the comparison is fair and dated:

   ```bash
   cd ~/my-security-portfolio/logslayer
   ./verify-base.sh
   sudo docker build --pull -f Dockerfile.standard -t logslayer:standard .
   sudo docker build -t logslayer:chainguard .
   ```

2. **Measure both**, and fill in the comparison table from [lesson 6](06-scan-it.md):

   ```bash
   sudo docker images logslayer
   sudo docker inspect --format '{{.Config.User}}' logslayer:standard logslayer:chainguard
   sudo grype logslayer:standard
   sudo grype logslayer:chainguard
   sudo docker run --rm --entrypoint sh logslayer:chainguard
   ```

3. **Prove it works** the way someone else would run it: from the image, on a read-only log, with no network:

   ```bash
   sudo docker run --rm --network none -v "$PWD/samples:/logs:ro" logslayer:chainguard /logs/auth.log
   ```

   `--network none` means the container has no network at all. `logslayer` doesn't need one, so it doesn't get one. That's least privilege again, and one more wall in the box.

4. **Write the README section.** Add a `## Running in a container` section to `logslayer/README.md` with:

   - The `docker run` command from step 3, and why each flag is there (`--rm`, `--network none`, `-v ...:ro`)
   - The before/after table, **with the scan date**
   - Three to five sentences on why the Chainguard image is safer: size, user, shell, CVEs
   - How you verify the base images, and why pinning a digest isn't enough on its own
   - When and how you update the pinned digests

5. **Commit and push**, and update the `logslayer` row in your portfolio's main README to mention the hardened image.

## With Claude

Ask Claude Code to review the finished work as a security engineer would:

```text
Review this project's Dockerfile, .dockerignore, and verify-base.sh as a
container security reviewer. Check them against this list: Chainguard base,
multi-stage, non-root, no shell in the final image, both stages pinned by
digest, signature verification that can actually fail, nothing unneeded
copied into the image. Report what passes and what doesn't. Don't change files.
```

**Check the work:** for each "pass," prove it with a command from this module. For each "fail," decide if Claude's right. Then ask it for one improvement **not** on the list, and judge whether it's worth doing. Examples it might suggest: a `HEALTHCHECK` (not much use for a CLI), a read-only root filesystem with `--read-only` (worth trying: does `logslayer` still run?), or dropping Linux capabilities with `--cap-drop=ALL` (also worth trying). Try anything you keep, and add it to your README.

## Done when

- [ ] Every box in "The image must be" is checked, and you can prove each one with a command
- [ ] The README has the before/after table, with the scan date
- [ ] `verify-base.sh` fails when you change the expected identity, and passes when you put it back
- [ ] You can explain, out loud, why a digest, a signature, and an SBOM each protect against something different

This is your supply chain story for interviews. Tell it with your numbers: "Hundreds of CVEs on the standard image, zero on mine, and here's how I make sure the base image is really Chainguard's."
