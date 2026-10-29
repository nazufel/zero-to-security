# Switch to Chainguard

**Pillars:** 🪪 Identity · 🤖 AI

## Why this matters

The standard image gave `logslayer` a gigabyte of software it doesn't use, and root. Every one of those programs is something to patch, and something an attacker can use if they get in. The fix is a **minimal image**: only what the app needs to run, as a non-root user.

[Chainguard's free images](https://images.chainguard.dev/) are built that way, and this course uses them as the default base for every Dockerfile. The trick is a **multi-stage build**: one image with tools to build the app, and a second, minimal image to run it.

> **Last verified:** 2026-10-29. Chainguard's free images are public, need no login, and are tagged only `latest` and `latest-dev`. `python:latest` runs as user `65532` (`nonroot`) and has no shell. ([Chainguard docs](https://www.chainguard.dev/docs/chainguard/containers/getting-started/languages-and-runtimes/python))

## Do it

1. Look at the two Chainguard Python images you'll use:

   | Image | Has | Use it to |
   |---|---|---|
   | `cgr.dev/chainguard/python:latest-dev` | Python, pip, a shell, build tools | **Build** your app |
   | `cgr.dev/chainguard/python:latest` | Python. That's it. | **Run** your app |

2. In `~/my-security-portfolio/logslayer`, create `Dockerfile`:

   ```dockerfile
   # Dockerfile: logslayer on Chainguard, built in two stages

   # Stage 1: build. The -dev image has a shell, pip, and build tools.
   FROM cgr.dev/chainguard/python:latest-dev AS build
   WORKDIR /app
   RUN python -m venv --without-pip /app/venv
   COPY --chown=65532:65532 pyproject.toml README.md ./
   COPY --chown=65532:65532 src ./src
   RUN pip --python /app/venv/bin/python install --no-cache-dir .

   # Stage 2: run. Only Python and logslayer. No shell, no pip.
   FROM cgr.dev/chainguard/python:latest
   WORKDIR /app
   COPY --from=build /app/venv /app/venv
   ENTRYPOINT ["/app/venv/bin/logslayer"]
   ```

   Read it in two halves:

   - **Stage 1** (`AS build`) makes a virtual environment ([Module 3](../03-python/09-packages.md)) and installs `logslayer` into it, using the tools in the `-dev` image. It copies only the three things the build needs, not the whole folder. `--chown=65532:65532` gives the files to the image's non-root user, who runs the build.
   - **Stage 2** starts fresh from the minimal image and copies in **only** the finished virtual environment. Everything else from stage 1, including pip, the shell, and the build tools, is left behind and never ships.

3. Build and run it:

   ```bash
   sudo docker build -t logslayer:chainguard .
   sudo docker run --rm -v "$PWD/samples:/logs:ro" logslayer:chainguard /logs/auth.log
   ```

   Same report as before.

4. Measure it the same way you measured the standard image:

   ```bash
   sudo docker images logslayer
   sudo docker inspect --format '{{.Config.User}}' logslayer:standard
   sudo docker inspect --format '{{.Config.User}}' logslayer:chainguard
   ```

   Roughly:

   ```
   REPOSITORY   TAG          IMAGE ID       CREATED          SIZE
   logslayer    chainguard   4e5f6a7b8c9d   30 seconds ago   80MB
   logslayer    standard     9c1d2e3f4a5b   1 hour ago       1.13GB

   65532
   ```

   The standard image's user is blank, which means root. The Chainguard image runs as `65532`, a user with no special rights. A fraction of the size, and not root. You'll count the vulnerabilities in lesson 6.

## Break it

Try to get a shell inside the running image:

```bash
sudo docker run --rm --entrypoint sh logslayer:chainguard
```

```
docker: Error response from daemon: failed to create task for container: ... exec: "sh": executable file not found in $PATH: unknown.
```

There's no shell. Try `bash`, `ls`, or `cat`: none of them exist either.

That's the point. A common attack on a container goes: find a bug in the app, use it to run a shell command, download more tools, move on. In this image, there's no shell to run, no `curl` to download with, and no package manager to install anything. **If you can't get a shell, neither can an attacker.**

It also means you can't debug it the usual way. When you need to look inside, run the `-dev` image with the same files, or use your logs. That trade-off is worth it in production.

## With Claude

Ask Claude Code:

```text
Read Dockerfile.standard and Dockerfile. Explain the security differences
between the two images, and tell me which of the problems you listed for
Dockerfile.standard the new Dockerfile fixes. Don't change anything.
```

**Check the work:** check each claim with a command. Claims about the user: `docker inspect`. Claims about size: `docker images`. Claims about "no shell": you just proved it. Did Claude say the Chainguard image "has no vulnerabilities"? That's a claim to test, not accept, and it's the next lesson.

> **Free AI path:** do this with OpenCode; the prompt is the same.

```bash
git add Dockerfile
git commit -m "Build logslayer on Chainguard with a multi-stage build"
git push
```

## Check yourself

1. In a multi-stage build, what ends up in the final image?
   <details><summary>Answer</summary>

   Only the last stage, plus whatever you `COPY --from` earlier stages. Build tools in earlier stages are left behind.
   </details>

2. Why does a missing shell make an image safer?
   <details><summary>Answer</summary>

   Many attacks need to run shell commands after getting in. With no shell, no download tools, and no package manager, an attacker has almost nothing to work with.
   </details>

3. Why use `latest-dev` in the first stage and `latest` in the second?
   <details><summary>Answer</summary>

   `latest-dev` has pip and build tools to install the app. `latest` has only what's needed to run it, so that's all that ships.
   </details>

## Go deeper

- [Docker: multi-stage builds](https://docs.docker.com/build/building/multi-stage/): the official guide.
- [Chainguard Academy](https://www.chainguard.dev/docs): free courses and guides on minimal images and supply chain security.
