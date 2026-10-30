# Run Elastic

**Pillars:** ☁️ Cloud · 🤖 AI

## Why this matters

A **SIEM** (security information and event management system) is where a SOC lives: logs from every server, cloud account, and app, in one place, searchable in seconds, with rules that turn suspicious patterns into alerts. You've done every piece by hand in this course: `grep` pipelines in [Module 2](../../02-linux/08-logs-and-pipes.md), CloudWatch alarms and Athena in [Module 9](../../09-incident-response/). A SIEM is all of it, together, at scale.

SIEMs are on most SOC job postings. **Elastic** (Elasticsearch, plus the Kibana web interface, plus Elastic Security) is one of the most common, and its core is free to run yourself.

> **You need more memory for this track.** Elasticsearch and Kibana together want about 3 GB on top of Ubuntu. Give your VM **6 GB or more** (shut it down, change its memory in UTM or VirtualBox, start it again). That usually means a laptop with 16 GB. On an 8 GB laptop, read along, or see the low-memory note in step 3.

## Do it

1. **Take a snapshot** of your VM. You're installing a lot.

2. **Get Elastic's installer, and read it.** Elastic publishes `start-local`, a script that runs Elasticsearch and Kibana in Docker for local development. Pin the version, and read before you run, as always:

   ```bash
   mkdir -p ~/elastic && cd ~/elastic
   curl -fsSL https://elastic.co/start-local -o start-local.sh
   less start-local.sh
   ```

   Look for three things: where it puts its files (`elastic-start-local/`), how it makes the password (random, stored in `.env`), and how it publishes ports (`127.0.0.1:9200` and `127.0.0.1:5601`). Remember [Module 5](../../05-containers/03-ports-and-volumes.md): a published Docker port goes around `ufw`. Binding to `127.0.0.1` is what keeps Elasticsearch off the network.

   ```bash
   sudo sh start-local.sh -v 9.5.5
   ```

   > **Last verified:** 2026-10-29 with start-local 0.14 and Elastic Stack 9.5.5 ([start-local](https://github.com/elastic/start-local)). It starts with a 30-day trial of paid features, then becomes the free **Basic** license. Everything in this track works on Basic.

3. **Find your password**, and check it's running:

   ```bash
   sudo grep ES_LOCAL_PASSWORD elastic-start-local/.env
   sudo docker ps --format '{{.Names}}\t{{.Ports}}'
   ```

   Both containers show `127.0.0.1:` in front of their ports.

   **Low on memory?** Edit `elastic-start-local/.env` (with `sudo nano`), set `ES_LOCAL_JAVA_OPTS="-Xms512m -Xmx1g"`, then `cd elastic-start-local && sudo ./stop.sh && sudo ./start.sh`. It'll be slower, but it runs.

4. **Reach Kibana from your laptop**, through SSH. Kibana only listens on the VM's localhost, so tunnel to it. **On your laptop:**

   ```bash
   ssh -L 5601:localhost:5601 lab
   ```

   Leave that session open, and browse to `http://localhost:5601` on your laptop. Log in as `elastic` with the password from step 3. `-L` forwards your laptop's port 5601, through the encrypted SSH connection, to the VM's. Nothing new is exposed to the network.

5. **Look around.** Open the menu: **Discover** (search), **Dashboards**, and **Security** (alerts and detection rules). You'll use all three.

6. Write `elastic/notes.md` in your portfolio: what a SIEM does, in your own words, and how each part maps to something you've built (`grep` → search, CloudWatch alarm → detection rule).

## Break it

Expose it the way people accidentally do. Look at what you'd get if you published the port to every interface. Don't change anything, just read:

```bash
sudo grep -n "9200" ~/elastic/elastic-start-local/docker-compose.yml
```

You'll see `127.0.0.1:${ES_LOCAL_PORT}:9200`. Remove `127.0.0.1:` and Elasticsearch would answer anyone who can reach the VM, ignoring `ufw`, protected only by a password, over plain HTTP.

Exposed Elasticsearch servers are one of the most common sources of large data leaks: researchers regularly find databases with millions of records open to the internet, often with no password at all. Write in your notes the three things that keep yours safe: localhost binding, a random password, and the VM itself.

## With Claude

Ask Claude Code:

```text
I'm running Elasticsearch and Kibana locally with Elastic's start-local
script, bound to 127.0.0.1 inside a VM. What would I need to change before
running this for a real team? Don't read the .env file.
```

**Check the work:** good answers include TLS on HTTP, individual user accounts instead of the shared `elastic` superuser, role-based access, snapshots for backup, and more than one node. Did it respect "don't read the .env file"? If your managed-settings deny rules ([Module 8](../../08-security-concepts/12-ai-in-a-box.md)) don't cover it, add `"Read(**/.env)"`. The `elastic` password can read and delete every log you'll put in here.

## Check yourself

1. What does a SIEM do that `grep` doesn't?
   <details><summary>Answer</summary>

   It collects logs from many systems in one place, searches them fast at scale, keeps history, and runs detection rules that raise alerts automatically.
   </details>

2. Why does `start-local` bind to `127.0.0.1`?
   <details><summary>Answer</summary>

   So only the VM itself can reach Elasticsearch and Kibana. Docker's published ports go around `ufw`, so the binding is what keeps them off the network.
   </details>

3. How does `ssh -L 5601:localhost:5601 lab` work?
   <details><summary>Answer</summary>

   It forwards your laptop's port 5601 through the encrypted SSH connection to port 5601 on the VM's localhost, so you can use Kibana without exposing it.
   </details>

## Go deeper

- [Elastic Security documentation](https://www.elastic.co/docs/solutions/security): what the Security app does, and what's in each license.
