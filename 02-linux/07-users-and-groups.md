# Users and groups

**Pillars:** 🪪 Identity

## Why this matters

When someone joins a team, IT creates their account and puts them in the right groups. When they leave, IT takes it away. When that second part gets skipped, ex-employees keep their access, sometimes for years. Forgotten accounts are a favorite way in for attackers, because nobody's watching them.

On Linux, groups decide what users can do, and one group matters more than any other: `sudo`.

## Do it

1. Who are you, and what groups are you in?

   ```bash
   whoami
   groups
   ```

   What you should see:

   ```
   yourusername
   yourusername adm cdrom sudo dip plugdev users lxd
   ```

   You're in `sudo`, which is why `sudo` works for you. The installer did that.

2. Every account on the system is a line in `/etc/passwd`:

   ```bash
   tail -5 /etc/passwd
   ```

   Despite the name, there are no passwords in here (those are in `/etc/shadow`, from lesson 4). Most lines are **service accounts** that programs run as, not people.

3. Add a user:

   ```bash
   sudo adduser alice
   ```

   Give alice a password. Press Enter through the name and phone questions.

4. Make a team group and add alice to it:

   ```bash
   sudo groupadd developers
   sudo usermod -aG developers alice
   groups alice
   ```

   ```
   alice : alice developers
   ```

5. Become alice to see the system from her side:

   ```bash
   su - alice
   whoami
   sudo ls /root
   ```

   ```
   alice is not in the sudoers file.
   ```

   Good. Alice can log in, but she can't act as root. Type `exit` to become yourself again.

6. Give alice admin rights, check, then take them away:

   ```bash
   sudo usermod -aG sudo alice
   groups alice
   sudo deluser alice sudo
   groups alice
   ```

   Granting and removing access should be equally easy, and equally routine.

7. Lock an account without deleting it (what you'd do the day someone leaves, before you know what to keep):

   ```bash
   sudo usermod -L alice
   sudo passwd -S alice
   ```

   An `L` in the output means locked. Unlock with `sudo usermod -U alice`.

Add `adduser`, `usermod -aG`, `groups`, `deluser`, and `usermod -L` to your cheat sheet.

## Break it

The most dangerous typo in user management. Put alice in `sudo` and `developers`, then "add" her to one more group, but forget the `-a`:

```bash
sudo usermod -aG sudo alice
sudo groupadd auditors
sudo usermod -G auditors alice
groups alice
```

What you should see:

```
alice : alice auditors
```

She's out of `developers` *and* `sudo`. Without `-a` (append), `-G` **replaces** all of a user's groups with the list you give. Run that on your own account and you can lose `sudo` on your own server, with no way to get it back except a snapshot or a recovery boot.

Clean up:

```bash
sudo deluser --remove-home alice
sudo groupdel developers
sudo groupdel auditors
```

## With Claude

Ask [claude.ai](https://claude.ai):

```text
A contractor needs to read log files in /var/log on my Ubuntu server for two
weeks. What's the least-privilege way to set up their account? Give me the
exact commands.
```

**Check the work:** does the answer give them `sudo`? That's far more than reading logs. Look for the `adm` group, which can read most logs on Ubuntu (check with `ls -l /var/log`). Then check every `usermod` command for the missing `-a`. And ask yourself: did Claude say how the access ends in two weeks? Removing access is half the job.

## Check yourself

1. You run `sudo usermod -G docker bob`. What just happened to bob?
   <details><summary>Answer</summary>

   He's now in `docker` and removed from every other secondary group, possibly including `sudo`. You needed `-aG` to append.
   </details>

2. An employee leaves today. Delete their account or lock it?
   <details><summary>Answer</summary>

   Lock it right away so it can't be used, then delete it once you've kept any files or evidence you need. Deleting first can destroy what an investigation needs.
   </details>

3. Why is membership in the `sudo` group such a big deal?
   <details><summary>Answer</summary>

   Members can run any command as root, and root ignores all permissions. A `sudo` user can do anything on the system.
   </details>

## Go deeper

- [Ubuntu: user management](https://documentation.ubuntu.com/server/how-to/security/user-management/): the official guide, including password policies and how `sudo` is configured.
