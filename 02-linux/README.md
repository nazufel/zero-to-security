# Module 2: Linux

**Pillars:** 🪪 Identity · 🤖 AI

> 🚧 **Outline.** Lessons are being written. The checklist and plan below are final.

## Why this module matters

Most servers, containers, and cloud workloads run Linux. When something breaks or gets attacked, the evidence is in a Linux log, and the fix happens at a Linux command line. You'll use these skills in every module after this one.

We keep it lean: only what you'll actually use.

## Opinions

- **Ubuntu Server LTS, no desktop.** It forces command-line comfort and runs on 4 GB of RAM.
- **Mac:** [UTM](https://mac.getutm.app/) (free). **Windows:** [VirtualBox](https://www.virtualbox.org/) (free, works on Windows Home). **Low on RAM?** WSL2 is the fallback.
- **The VM is also AI's first box.** Claude Code runs inside it, not on your laptop.

## You're ready to move on when…

- [ ] You can install Ubuntu Server in a VM and snapshot it before you break things
- [ ] You can move around the filesystem and find any file without a mouse
- [ ] You can create, copy, move, edit, and delete files from the command line
- [ ] You can read and change file permissions, and explain what `600` and `755` mean
- [ ] You can update the system and install a package with `apt`
- [ ] You can start, stop, enable, and check a service with `systemctl`
- [ ] You can add a user, put them in a group, and give or take away `sudo`
- [ ] You can find a failed login in the logs with `journalctl` or `grep`
- [ ] You can SSH into your VM with a key, and have password login turned off
- [ ] You can write a short Bash script with a variable and a loop
- [ ] You can run Claude Code in the VM and explain every command before you approve it

## Lessons (planned)

1. **Install Ubuntu in a VM** (UTM on Mac, VirtualBox on Windows) and take your first snapshot
2. **Finding your way:** `pwd`, `ls`, `cd`, `find`, tab completion
3. **Working with files:** `touch`, `cp`, `mv`, `rm`, `mkdir`, `cat`, `less`, `nano`
4. **Permissions:** `chmod`, `chown`, `sudo`. *Break it:* read another user's private file. *(Identity starts here.)*
5. **Packages:** `apt update`, `apt upgrade`, `apt install`, and why unpatched software gets you breached
6. **Services:** `systemctl` and what's running on your machine
7. **Users and groups:** `adduser`, `usermod`, `groups`, the `sudo` group
8. **Logs and pipes:** `journalctl`, `/var/log/auth.log`, `grep`, `|`
9. **SSH:** key pairs, `ssh-copy-id`, disabling password login
10. **Bash scripting basics:** variables, loops, one useful script
11. **Claude Code in the box:** install it in the VM, permission modes, why you never approve `sudo` blindly

## Practice

- **Challenge:** [OverTheWire Bandit](https://overthewire.org/wargames/bandit/), levels 0–15
- **Project:** harden your VM: new admin user, SSH keys only, password login off, firewall (`ufw`) on, automatic security updates. Write it as a script **by hand**, then have Claude write one, and diff the two. Commit both with a README explaining every line.

## Dig Deeper

- Regex for log hunting
- [The Linux Command Line](https://linuxcommand.org/tlcl.php) by William Shotts (free book)
