# Module 2 quiz

Answer each question out loud or on paper *before* you open the answer. Better yet, answer it at your VM's command line.

1. You're about to change the SSH config on your VM. What two things do you do first?
   <details><summary>Answer</summary>

   Take a snapshot (or at least back up the file with `cp`), and keep your current SSH session open so you can fix a lockout from it.
   </details>

2. You need to find a file called `nginx.conf` but don't know where it is. What do you run?
   <details><summary>Answer</summary>

   `find / -name "nginx.conf" 2>/dev/null`. The `2>/dev/null` hides "Permission denied" noise.
   </details>

3. What does this mean? `-rwxr-x--- 1 alice developers 812 Mar 14 deploy.sh`
   <details><summary>Answer</summary>

   A file owned by alice and the `developers` group. Alice can read, write, and run it (`rwx`). The group can read and run it (`r-x`). Everyone else can't touch it (`---`). In numbers: `750`.
   </details>

4. A file holding an API key has permissions `644`. What do you change it to, and why?
   <details><summary>Answer</summary>

   `chmod 600`. With `644`, every user on the system can read the key. `600` limits it to the owner.
   </details>

5. Put these in the right order to patch a server: `apt upgrade`, `apt update`.
   <details><summary>Answer</summary>

   `sudo apt update` first (refresh the list of what's available), then `sudo apt upgrade` (install it).
   </details>

6. A website is down. Which two commands tell you why?
   <details><summary>Answer</summary>

   `systemctl status <service>` for whether it's running and its last log lines, then `journalctl -u <service>` for the full logs.
   </details>

7. You run `sudo usermod -G docker yourname`. Why might you have just lost `sudo`?
   <details><summary>Answer</summary>

   Without `-a`, `-G` replaces all your secondary groups with only `docker`, which removes you from `sudo`. Always use `-aG`.
   </details>

8. Write a pipeline that counts failed SSH password attempts per IP in `/var/log/auth.log`, worst first.
   <details><summary>Answer</summary>

   `sudo grep "Failed password" /var/log/auth.log | grep -oE "from [0-9.]+" | sort | uniq -c | sort -rn`
   </details>

9. Your `01-hardening.conf` says `PasswordAuthentication no`, but password login still works. What do you check?
   <details><summary>Answer</summary>

   `sudo sshd -T | grep -i passwordauthentication` to see what SSH actually uses, and `ls /etc/ssh/sshd_config.d/` for another file that sets it first. Also: did you restart SSH after the change?
   </details>

10. Claude Code in your VM asks to run `sudo rm -rf /var/log/*` "to free up disk space." What's wrong, and what do you do?
    <details><summary>Answer</summary>

    It would delete every log on the system, including the evidence you'd need in an investigation. Say no. And it shouldn't be able to: your deny rule blocks `sudo`. Find out what's actually using the disk (`df -h`, then `sudo du -sh /var/log/*`) and decide yourself.
    </details>

## Challenge

Play [OverTheWire Bandit](https://overthewire.org/wargames/bandit/), levels 0 to 15. It's a game you play over SSH, built to be attacked, so it's on your [allowed list](../00-start-here/02-ethics-and-the-law.md). Every level uses commands from this module.

Two rules: don't look up the answers, and add a row to your [stuck log](../00-start-here/05-getting-unstuck.md) every time a level takes you more than 20 minutes. If you ask Claude, ask for a hint, not the answer.
