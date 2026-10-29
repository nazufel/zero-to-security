# Why containers

**Pillars:** 🪪 Identity · 🤖 AI

## Why this matters

A **container** is an app packaged with exactly what it needs to run: its code, its libraries, its settings. It runs the same way on your VM, a teammate's laptop, and a cloud server. That's why so much modern software ships in containers, and why so much of what you'll defend runs in them.

Containers are also a box, the second one in this course after the VM. A program in a container sees only what you give it. But the box has rules, and one of them surprises almost everyone: whoever controls Docker controls the whole machine.

## Do it

1. **Install Docker Engine in your VM**, from Docker's own package repository. Not on your laptop: the VM is the sandbox.

   > **Last verified:** 2026-10-29 ([Docker docs](https://docs.docker.com/engine/install/ubuntu/)). Ubuntu 26.04 is supported. If these steps have changed, follow the docs.

   First, add Docker's **signing key**. apt uses it to check that every package really came from Docker and wasn't tampered with. It's the same idea as the hashes in [Module 4](../04-networking/07-crypto-basics.md):

   ```bash
   sudo apt update
   sudo apt install -y ca-certificates curl
   sudo install -m 0755 -d /etc/apt/keyrings
   sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
   sudo chmod a+r /etc/apt/keyrings/docker.asc
   ```

   Then tell apt where Docker's packages live, and install them:

   ```bash
   sudo tee /etc/apt/sources.list.d/docker.sources <<EOF
   Types: deb
   URIs: https://download.docker.com/linux/ubuntu
   Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
   Components: stable
   Signed-By: /etc/apt/keyrings/docker.asc
   EOF
   sudo apt update
   sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
   ```

2. Check that it works:

   ```bash
   sudo docker run --rm hello-world
   ```

   ```
   Hello from Docker!
   This message shows that your installation appears to be working correctly.
   ```

   Docker downloaded an **image** (a packaged app, like a template), started a **container** from it (a running copy), printed the message, and `--rm` deleted the container when it finished.

3. See the big difference between a container and your VM. Check the kernel version on the VM, then inside a container:

   ```bash
   uname -r
   sudo docker run --rm cgr.dev/chainguard/wolfi-base uname -r
   ```

   **The same.** A VM runs a whole separate operating system, with its own kernel. A container is just a process on your VM, fenced off so it sees its own files and network. It shares the VM's kernel.

   Now check the operating system:

   ```bash
   grep PRETTY_NAME /etc/os-release
   sudo docker run --rm cgr.dev/chainguard/wolfi-base grep PRETTY_NAME /etc/os-release
   ```

   Ubuntu outside, Wolfi inside. Each container brings its own files and programs. It just borrows the kernel.

   | | **VM** | **Container** |
   |---|---|---|
   | What's inside | A whole operating system, with its own kernel | An app and its files, sharing the host's kernel |
   | Starts in | Minutes | Under a second |
   | Size | Gigabytes | Megabytes |
   | Isolation | Strong: a separate machine | Good, but it's still a process on the host |

   That last row is why this course uses **both**: containers inside a VM. If something escapes a container, it's still in the VM.

> **Why `sudo docker` every time?** Many guides tell you to add yourself to the `docker` group so you can skip `sudo`. Don't. The Break it step shows why.

## Break it

See what "whoever controls Docker controls the machine" means. A container can **mount** a folder from the host (lesson 3). Mount the VM's whole filesystem, and read a file only root can read:

```bash
sudo docker run --rm -v /:/host cgr.dev/chainguard/wolfi-base cat /host/etc/shadow
```

There are your password hashes, from [Module 2](../02-linux/04-permissions.md). Anyone who can run `docker` can do this, and much worse. That's why **membership in the `docker` group is the same as root**. If you added yourself to it, then any program running as you could own the VM, including an AI agent. Your Claude Code deny rule for `sudo` ([Module 2](../02-linux/11-claude-code-in-the-box.md)) would mean nothing, because `docker run -v /:/host` doesn't need `sudo`.

With `sudo docker`, that rule still holds: Claude Code can write Dockerfiles, but you run the builds.

## With Claude

In Claude Code, ask:

```text
What's the difference between a container and a virtual machine? Then
explain why adding a user to the docker group is a security risk.
```

**Check the work:** you just proved both answers yourself, with `uname -r` and the `/etc/shadow` mount. Does Claude's explanation match what you saw? Does it mention rootless Docker or Podman as alternatives? If so, note them; they're real options, and this course sticks with `sudo docker` to keep things simple. If Claude says adding yourself to the `docker` group is "the recommended post-install step," it's repeating a convenience tip, not security advice. Log it in your [AI check log](../01-ai-foundations/01-what-ai-is.md).

## Check yourself

1. A container and its host report the same `uname -r`. Why?
   <details><summary>Answer</summary>

   Containers share the host's kernel. Only VMs run their own.
   </details>

2. Why is the `docker` group equivalent to root?
   <details><summary>Answer</summary>

   Anyone who can run Docker can mount the host's whole filesystem into a container and read or change anything, including `/etc/shadow`.
   </details>

3. Why run containers inside a VM in this course?
   <details><summary>Answer</summary>

   Two boxes. Containers share the kernel, so isolation is good but not perfect. If something escapes a container, it's still inside a VM you can restore.
   </details>

## Go deeper

- [Docker Engine security](https://docs.docker.com/engine/security/): the official explanation of the docker group, kernel sharing, and rootless mode.
