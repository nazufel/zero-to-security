# Running containers

## Why this matters

On a team that runs containers, "the app is down" means "a container stopped." You'll check which containers are running, read their logs, and restart them, the same way you used `systemctl` and `journalctl` for services in [Module 2](../02-linux/06-services.md). Six commands cover almost all of it.

## Do it

1. Run a web server in the background. Chainguard's `nginx` image is minimal and runs as a non-root user:

   ```bash
   sudo docker run -d --name web cgr.dev/chainguard/nginx
   ```

   `-d` runs it **detached**, in the background. `--name web` gives it a name you can use instead of a random ID.

2. List running containers:

   ```bash
   sudo docker ps
   ```

   ```
   CONTAINER ID   IMAGE                      COMMAND                  CREATED         STATUS         PORTS     NAMES
   3f2a91c0b7d4   cgr.dev/chainguard/nginx   "/usr/sbin/nginx -c …"   5 seconds ago   Up 4 seconds             web
   ```

3. Read its logs:

   ```bash
   sudo docker logs web
   sudo docker logs -f web
   ```

   `-f` follows new lines as they arrive, like `tail -f`. `Ctrl+C` stops following; the container keeps running.

4. Look inside a running container with `exec`. nginx's image has no shell (you'll see why that matters in lesson 5), so start a second container that does have one:

   ```bash
   sudo docker run -d --name toolbox cgr.dev/chainguard/wolfi-base sleep 3600
   sudo docker exec -it toolbox sh
   ```

   You're inside. Try `whoami`, `ls /`, and `ps`. Type `exit` to leave. `-it` gives you an interactive terminal.

5. Stop and remove:

   ```bash
   sudo docker stop web toolbox
   sudo docker ps
   sudo docker ps -a
   sudo docker rm web toolbox
   ```

   `ps` shows only running containers. `ps -a` shows stopped ones too. A stopped container still exists, with its logs and any files it wrote, until you `rm` it.

6. Clean up images you're not using:

   ```bash
   sudo docker images
   sudo docker image prune -a
   ```

| Command | What it does |
|---|---|
| `docker run` | Create and start a container from an image |
| `docker ps` / `ps -a` | List running / all containers |
| `docker logs` | Show a container's output |
| `docker exec` | Run a command inside a running container |
| `docker stop` | Stop a container |
| `docker rm` | Delete a stopped container |

Add these to your Linux cheat sheet, with `sudo` in front.

## Break it

Two errors you'll hit in your first week:

```bash
sudo docker run -d --name web cgr.dev/chainguard/nginx
sudo docker run -d --name web cgr.dev/chainguard/nginx
```

```
docker: Error response from daemon: Conflict. The container name "/web" is already in use by container "3f2a91c0b7d4...". You have to remove (or rename) that container to be able to reuse that name.
```

Names are unique. Now try to remove the running one:

```bash
sudo docker rm web
```

```
Error response from daemon: cannot remove container "web": container is running: stop the container before removing or force remove
```

Docker won't delete a running container unless you force it with `-f`. Both errors say exactly what to do. Stop and remove it the normal way:

```bash
sudo docker stop web && sudo docker rm web
```

## With Claude

Start a container that fails on purpose:

```bash
sudo docker run -d --name broken cgr.dev/chainguard/nginx -c /etc/nginx/missing.conf
sudo docker ps -a
sudo docker logs broken
```

Paste the `ps -a` and `logs` output into Claude Code:

```text
This container exited right after starting. What went wrong, and how would
I find out on my own next time?
```

**Check the work:** did Claude read the actual error in the logs, or guess a common cause? The answer is in the log line. Did it suggest `docker logs` and `docker ps -a` as the first places to look? That's the method: same as `systemctl status` and `journalctl`. Clean up with `sudo docker rm broken`.

## Check yourself

1. A container isn't in `docker ps`. Is it gone?
   <details><summary>Answer</summary>

   Not necessarily. It may have stopped. `docker ps -a` shows stopped containers, and `docker logs` still works on them.
   </details>

2. How do you read the output of a container running in the background?
   <details><summary>Answer</summary>

   `docker logs <name>`, or `docker logs -f <name>` to follow it.
   </details>

3. What's the difference between an image and a container?
   <details><summary>Answer</summary>

   An image is the packaged template. A container is a running (or stopped) copy made from it. One image can start many containers.
   </details>

## Go deeper

- [Docker CLI reference: `docker run`](https://docs.docker.com/reference/cli/docker/container/run/): every flag, officially.
