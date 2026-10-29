# Ports and volumes

**Pillars:** ☁️ Cloud

## Why this matters

A container starts sealed off: its own network, its own files. **Ports** and **volumes** are the two ways you open it up. Each one is a decision about exposure, the same decisions you made with [firewalls](../04-networking/08-firewalls.md) and [permissions](../02-linux/04-permissions.md). Open a port too widely and the internet can reach it. Mount a folder read-write and the container can change your files.

## Do it

1. **Ports.** Run nginx and publish its port:

   ```bash
   sudo docker run -d --name web -p 127.0.0.1:8080:8080 cgr.dev/chainguard/nginx
   curl -s localhost:8080 | head -5
   ```

   Read `-p 127.0.0.1:8080:8080` as **host-address:host-port:container-port**: "connections to port 8080 on the VM's loopback go to port 8080 in the container." Chainguard's nginx listens on 8080, not 80, because a non-root user can't use ports below 1024.

   ```bash
   sudo ss -tlnp | grep 8080
   ```

   It's bound to `127.0.0.1`: only the VM itself can reach it ([Module 4](../04-networking/03-tcp-udp-ports.md)).

2. **Volumes.** Give a container access to a folder on the VM with `-v host-folder:container-folder`. Make some evidence to work with:

   ```bash
   mkdir -p ~/evidence
   cp ~/my-security-portfolio/logslayer/samples/auth.log ~/evidence/
   sudo docker run --rm -v ~/evidence:/evidence:ro cgr.dev/chainguard/wolfi-base grep -c "Failed password" /evidence/auth.log
   ```

   ```
   22
   ```

   The container read the log through the volume. `:ro` makes it **read-only**.

3. Clean up the web server:

   ```bash
   sudo docker rm -f web
   ```

## Break it

**Part 1: Docker goes around your firewall.** Your VM's firewall denies everything except SSH ([Module 4](../04-networking/08-firewalls.md)). Publish a port the "normal" way, without an address:

```bash
sudo docker run -d --name web -p 8080:8080 cgr.dev/chainguard/nginx
sudo ufw status
```

ufw still says only SSH is allowed. Now, **from your laptop**:

```bash
curl --max-time 5 http://192.168.64.5:8080/ | head -3
```

It works. Docker publishes ports by writing its own firewall rules, which take effect before ufw's. `-p 8080:8080` means "on **every** interface," so the container is reachable from the network no matter what ufw says. On a cloud server with a public IP, that's the internet. This catches experienced engineers all the time.

The fix is the habit from step 1: publish to `127.0.0.1` unless you really mean the network, and when you do, choose the address on purpose.

```bash
sudo docker rm -f web
```

**Part 2: a read-write volume lets the container change your files.** Mount the evidence folder without `:ro`, and have the container "clean up":

```bash
sudo docker run --rm -v ~/evidence:/evidence cgr.dev/chainguard/wolfi-base sh -c 'echo "nothing to see here" > /evidence/auth.log'
cat ~/evidence/auth.log
```

```
nothing to see here
```

The evidence on your VM is gone, changed from inside the container. Now try the same thing with `:ro`:

```bash
cp ~/my-security-portfolio/logslayer/samples/auth.log ~/evidence/
sudo docker run --rm -v ~/evidence:/evidence:ro cgr.dev/chainguard/wolfi-base sh -c 'echo "nothing to see here" > /evidence/auth.log'
```

```
sh: can't create /evidence/auth.log: Read-only file system
```

**Mount only what the container needs, read-only unless it must write.** Least privilege, for files.

## With Claude

Ask Claude Code:

```text
Write a docker run command for an nginx container that serves files from
~/site on my Ubuntu server, reachable at port 8080.
```

**Check the work:**

- Is the port published to every interface (`-p 8080:8080`)? That bypasses ufw. Is that what you want?
- Is the volume read-only (`:ro`)? A web server serving files doesn't need to change them.
- Is it the Chainguard image or `nginx:latest`? Is it pinned? (Lesson 7.)
- Did it mount anything you didn't ask for, like the Docker socket (`/var/run/docker.sock`)? That's the `docker` group problem from lesson 1, handed to a container.

## Check yourself

1. Read `-p 127.0.0.1:5432:5432`.
   <details><summary>Answer</summary>

   Connections to port 5432 on the host's loopback go to port 5432 in the container. Only the host itself can reach it.
   </details>

2. ufw denies port 8080, but `docker run -p 8080:8080` is reachable from your laptop. Why?
   <details><summary>Answer</summary>

   Docker writes its own firewall rules for published ports, and they apply before ufw's. Publishing without an address binds every interface.
   </details>

3. A container only needs to read logs from `/var/log`. How do you mount it?
   <details><summary>Answer</summary>

   Read-only: `-v /var/log:/logs:ro`. Better still, mount only the one file or folder it needs.
   </details>

## Go deeper

- [Docker docs: packet filtering and firewalls](https://docs.docker.com/engine/network/packet-filtering-firewalls/): the official explanation of how Docker and ufw interact.
