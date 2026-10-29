# Finding your way

## Why this matters

On day one of a SOC job, someone will say "check the SSH config" or "pull the auth logs." Nobody will tell you where those live. Every Linux server is laid out the same way, so once you know the map, you can find your way around any of them without a mouse.

## Do it

SSH into your VM. Everything in this module happens there unless it says "on your laptop."

1. Where are you?

   ```bash
   pwd
   ```

   What you should see:

   ```
   /home/yourusername
   ```

   `pwd` prints your working directory. This is your **home directory**, written as `~` for short.

2. What's here?

   ```bash
   ls
   ls -la
   ```

   Plain `ls` shows nothing: your home looks empty. `ls -la` shows **all** files in a **long** format, including hidden ones that start with a dot, like `.bashrc` and `.ssh`. Attackers like hiding things in dotfiles for exactly this reason.

3. Move around. Try each one, and run `pwd` after each:

   ```bash
   cd /
   cd /var/log
   cd ..
   cd ~
   cd -
   ```

   `/` is the top of everything. `..` is one level up. `~` is home. `-` is wherever you just were.

4. Tour the places you'll visit most:

   | Path | What lives there | You'll use it for |
   |---|---|---|
   | `/etc` | System configuration | SSH config, users, firewall |
   | `/var/log` | Logs | Finding failed logins, investigating incidents |
   | `/home` | Users' home directories | Your files, other users' files |
   | `/tmp` | Temporary files, wiped on reboot | Scratch work. A favorite attacker drop zone. |
   | `/usr/bin` | Installed programs | Finding out what a command really is |

   ```bash
   ls /etc
   ls /var/log
   ls /home
   ```

5. Stop typing full names. Type `cd /var/lo` and press **Tab**. It completes to `/var/log/`. Type `ls /etc/ss` and press Tab twice to see every match. Tab completion saves time and catches typos before you make them.

6. Find a file when you don't know where it is:

   ```bash
   find /etc -name "sshd_config"
   ```

   What you should see:

   ```
   /etc/ssh/sshd_config
   find: '/etc/ssl/private': Permission denied
   ```

   You may see a few more `Permission denied` lines. You found the SSH server's config file. Hide the noise about folders you can't read:

   ```bash
   find / -name "sshd_config" 2>/dev/null
   ```

   `2>/dev/null` throws away error messages. Use it when you know the errors don't matter.

7. Read the manual for any command:

   ```bash
   man ls
   ```

   Press `/` to search, `q` to quit. The manual is the source of truth. You used it in [Module 1](../01-ai-foundations/01-what-ai-is.md) to catch AI inventing a flag.

## Break it

Go somewhere you're not allowed:

```bash
ls /root
```

What you should see:

```
ls: cannot open directory '/root': Permission denied
```

`/root` is the home directory of **root**, the all-powerful admin account. Your user can't look inside. That's permissions doing their job. You'll learn to read them in lesson 4.

Now try:

```bash
cd /etc/hostname
```

```
-bash: cd: /etc/hostname: Not a directory
```

It's a file, not a folder. Read errors literally: they almost always say exactly what's wrong.

## With Claude

```bash
ls -la /etc/ssh
```

Paste the output into [claude.ai](https://claude.ai):

```text
I'm learning Linux. Explain what each file in this folder is for, and which
ones would matter most to an attacker.
```

**Check the work:** pick two files Claude described and check them. `man sshd_config` and `man ssh_config` explain the two config files. Did Claude mix up the client config (`ssh_config`) and the server config (`sshd_config`)? It's a common slip, and a real one: editing the wrong file does nothing.

## Check yourself

1. You're in `/var/log` and type `cd ..`. Where are you now?
   <details><summary>Answer</summary>

   `/var`. `..` is always one level up.
   </details>

2. Where would you look first for a system's configuration files? For its logs?
   <details><summary>Answer</summary>

   `/etc` for configuration, `/var/log` for logs.
   </details>

3. `ls` shows an empty home directory, but you suspect something's hidden. What do you run?
   <details><summary>Answer</summary>

   `ls -la`. The `-a` shows hidden dotfiles.
   </details>

## Go deeper

- [The Linux filesystem explained](https://www.pathname.com/fhs/): the Filesystem Hierarchy Standard, the official reason every Linux server is laid out the same way.
