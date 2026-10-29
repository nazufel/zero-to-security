# Services

## Why this matters

A **service** is a program that runs in the background: a web server, the SSH server, a database. Services are what a server is *for*, and they're also how attackers get in. Every running service that listens on the network is a door.

"The website is down" is one of the most common tickets you'll get. Nine times out of ten, the answer starts with `systemctl status`.

## Do it

1. Install a web server to practice on:

   ```bash
   sudo apt install -y nginx
   ```

2. Check on it:

   ```bash
   systemctl status nginx
   ```

   What you should see (trimmed):

   ```
   ● nginx.service - A high performance web server and a reverse proxy server
        Loaded: loaded (/usr/lib/systemd/system/nginx.service; enabled; preset: enabled)
        Active: active (running) since Sat 2026-03-14 02:20:11 UTC; 5s ago
   ```

   Three things to read every time:
   - **Active:** is it running right now?
   - **enabled:** will it start on boot?
   - **The log lines at the bottom:** what it said most recently.

   Press `q` to get your prompt back.

3. Prove it's working:

   ```bash
   curl -s localhost | head -5
   ```

   You'll see the start of nginx's "Welcome" page.

4. Control it. Run `systemctl status nginx` after each one to see the change:

   ```bash
   sudo systemctl stop nginx
   sudo systemctl start nginx
   sudo systemctl restart nginx
   sudo systemctl disable nginx
   sudo systemctl enable nginx
   ```

   `stop` and `start` are about **now**. `disable` and `enable` are about **next boot**. A service can be running but disabled, or stopped but enabled. Mixing these up is how a "fixed" server breaks again after a reboot.

5. See everything that's running:

   ```bash
   systemctl list-units --type=service --state=running
   ```

6. See which services are listening on the network, the doors:

   ```bash
   sudo ss -tlnp
   ```

   Look for `:22` (SSH) and `:80` (nginx). You'll learn what ports are in Module 4. For now: each line is a program waiting for connections from outside.

Add `systemctl status/start/stop/restart/enable/disable` and `ss -tlnp` to your cheat sheet.

## Break it

**Snapshot first** if you want the easy way back. Then break nginx's config. Add a line of garbage to the top of its main config file:

```bash
sudo cp /etc/nginx/nginx.conf /etc/nginx/nginx.conf.bak
sudo sed -i '1i this is not valid' /etc/nginx/nginx.conf
sudo systemctl restart nginx
```

What you should see:

```
Job for nginx.service failed because the control process exited with error code.
See "systemctl status nginx.service" and "journalctl -xeu nginx.service" for details.
```

The error tells you exactly where to look. Do what it says:

```bash
systemctl status nginx
sudo journalctl -u nginx --no-pager | tail -5
```

Somewhere in there:

```
nginx: [emerg] unknown directive "this" in /etc/nginx/nginx.conf:1
```

File name, line number, and the problem. Many programs can also check their own config before you restart:

```bash
sudo nginx -t
```

Fix it from your backup and restart:

```bash
sudo cp /etc/nginx/nginx.conf.bak /etc/nginx/nginx.conf
sudo nginx -t
sudo systemctl restart nginx
```

**The habit:** test the config, *then* restart. A failed restart takes down a service that was working fine a second ago.

## With Claude

```bash
systemctl list-units --type=service --state=running --no-pager
```

Paste the output into [claude.ai](https://claude.ai):

```text
This is a fresh Ubuntu Server VM I use for learning. Which of these services
do I actually need? Which could I safely disable to reduce attack surface?
```

**Check the work:** **don't disable anything yet.** For each service Claude says you can turn off, run `systemctl status <name>` and read what it does. Watch especially for `ssh`: if Claude suggests disabling it, that's the service you're connected through. Disable that and you've locked yourself out.

When you're done, remove nginx. You won't need it again in this module, and an unneeded service is an unneeded door:

```bash
sudo apt purge -y nginx nginx-common
sudo apt autoremove -y
```

## Check yourself

1. A service is "active (running)" but "disabled". What happens after a reboot?
   <details><summary>Answer</summary>

   It won't start. `enabled`/`disabled` only controls what starts at boot.
   </details>

2. `systemctl restart` fails. Where do you look?
   <details><summary>Answer</summary>

   `systemctl status <service>` for a summary, then `journalctl -u <service>` for the full logs. The error message usually names the file and line.
   </details>

3. Why test a config with something like `nginx -t` before restarting?
   <details><summary>Answer</summary>

   A restart with a broken config takes down a service that was running fine. Testing first catches the mistake while the old version keeps running.
   </details>

## Go deeper

- [systemd.io](https://systemd.io/): the official systemd site, for when you want to know how services really start.
