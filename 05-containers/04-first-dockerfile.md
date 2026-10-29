# Your first Dockerfile

**Pillars:** 🤖 AI

## Why this matters

A **Dockerfile** is the recipe for an image: start from this base, copy these files, run these commands. It's how `logslayer` stops being "a project on my VM" and becomes something anyone can run anywhere with one command.

This lesson builds it the way most tutorials do, on the standard `python` image. It works. In the next two lessons, you'll find out what it costs.

## Do it

1. Go to your project from [Module 3](../03-python/project.md):

   ```bash
   cd ~/my-security-portfolio/logslayer
   ```

2. Tell Docker what **not** to copy into the image. Create `.dockerignore`:

   ```text
   .venv/
   .git/
   __pycache__/
   .env
   ```

   Anything in the folder that isn't listed here can end up inside the image, and anyone who has the image can read it.

3. Create `Dockerfile.standard`:

   ```dockerfile
   # Dockerfile.standard: logslayer on the standard python image
   FROM python:3.14
   WORKDIR /app
   COPY . .
   RUN pip install --no-cache-dir .
   ENTRYPOINT ["logslayer"]
   ```

   | Line | What it does |
   |---|---|
   | `FROM python:3.14` | Start from the official Python image on Docker Hub |
   | `WORKDIR /app` | Make `/app` the working folder inside the image |
   | `COPY . .` | Copy the project folder into `/app` |
   | `RUN pip install --no-cache-dir .` | Install `logslayer` and its `logslayer` command |
   | `ENTRYPOINT ["logslayer"]` | Run `logslayer` when a container starts. Arguments go after the image name. |

4. Build it:

   ```bash
   sudo docker build -f Dockerfile.standard -t logslayer:standard .
   ```

   `-t` gives the image a name and **tag**. The `.` at the end is the **build context**: the folder Docker can copy from.

5. Run it on the sample log, mounted read-only ([lesson 3](03-ports-and-volumes.md)):

   ```bash
   sudo docker run --rm -v "$PWD/samples:/logs:ro" logslayer:standard /logs/auth.log
   ```

   ```
   Failed SSH logins by IP in /logs/auth.log
     203.0.113.7         12
     198.51.100.23        5
     192.0.2.44           3
     10.0.2.2             1
   Skipped 1 line(s) that couldn't be parsed
   ```

   Same tool, same output, now in a container. (Plus your `--top` and `--json` flags from Module 3, if you add them after the path.)

6. Now look at what you built:

   ```bash
   sudo docker images logslayer
   sudo docker run --rm --entrypoint whoami logslayer:standard
   sudo docker run --rm --entrypoint sh logslayer:standard -c 'ls /usr/bin | wc -l'
   ```

   Roughly:

   ```
   REPOSITORY   TAG        IMAGE ID       CREATED         SIZE
   logslayer    standard   9c1d2e3f4a5b   2 minutes ago   1.13GB
   root
   900
   ```

   Over a gigabyte, to run a script of about 60 lines. It runs as **root**. And it ships hundreds of programs, a shell, a compiler, `curl`, `apt`, that `logslayer` never uses but an attacker who got in would love. Write those numbers down. Lesson 5 will beat them.

## Break it

Bake a secret into an image by accident. Make a fake `.env` file, the kind developers keep API keys in, and remove it from `.dockerignore`:

```bash
echo "API_KEY=sk-FAKE-do-not-ship" > .env
sed -i '/^\.env$/d' .dockerignore
sudo docker build -q -f Dockerfile.standard -t logslayer:leaky .
sudo docker run --rm --entrypoint cat logslayer:leaky /app/.env
```

```
API_KEY=sk-FAKE-do-not-ship
```

`COPY . .` copied everything, and now the secret is inside the image. If you pushed this image to a registry, anyone who could pull it could read the key, and deleting the file in a later step wouldn't help: every step of an image is kept as a **layer**, just like Git keeps every commit ([Module 0](../00-start-here/03-git-and-github.md)).

Put it right, and clean up:

```bash
echo ".env" >> .dockerignore
rm .env
sudo docker rmi logslayer:leaky
```

**The rules:** keep a `.dockerignore`, copy only the files you need, and never put secrets in an image. They get passed in when the container runs (Module 6).

## With Claude

In `~/my-security-portfolio/logslayer`, ask Claude Code:

```text
Review Dockerfile.standard for security problems. Don't change it. List
each problem, why it matters, and how you'd fix it.
```

**Check the work:** compare its list with what you measured in step 6. It should mention running as root and the size of the base image. Does it mention that `COPY . .` copies more than needed? Did it suggest "add `USER nobody`" without checking that `logslayer` still runs? Any fix it suggests, you'd need to build and run to prove. Save its list; you'll compare it with the Chainguard version in the next lesson.

> **Free AI path:** do this with OpenCode; the prompt is the same.

```bash
git add .dockerignore Dockerfile.standard
git commit -m "Containerize logslayer on the standard python image"
git push
```

## Check yourself

1. What's the build context, and why does `.dockerignore` matter?
   <details><summary>Answer</summary>

   The folder Docker can copy files from. Without a `.dockerignore`, `COPY . .` can copy secrets, Git history, and junk into the image.
   </details>

2. You delete a secret file in a later `RUN rm` step. Is it gone from the image?
   <details><summary>Answer</summary>

   No. It's still in the earlier layer, and anyone with the image can extract it. Keep it out of the image in the first place.
   </details>

3. What's the difference between `ENTRYPOINT` and the arguments after the image name in `docker run`?
   <details><summary>Answer</summary>

   `ENTRYPOINT` is the program that runs. The arguments after the image name are passed to it, like `/logs/auth.log`.
   </details>

## Go deeper

- [Docker: build context and .dockerignore](https://docs.docker.com/build/concepts/context/): what gets sent to the builder, and how to keep things out.
