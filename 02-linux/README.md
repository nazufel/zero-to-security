# Module 2: Linux

**Pillars:** 🪪 Identity · 🤖 AI

## Why this module matters

Most servers, containers, and cloud workloads run Linux. When something breaks or gets attacked, the evidence is in a Linux log, and the fix happens at a Linux command line. You'll use these skills in every module after this one.

We keep it lean: only what you'll actually use.

## Opinions

- **Ubuntu Server LTS, no desktop.** It forces command-line comfort and runs on 4 GB of RAM.
- **Mac:** [UTM](https://mac.getutm.app/) (free). **Windows:** [VirtualBox](https://www.virtualbox.org/) (free, works on Windows Home), with a host-only network so only your laptop can reach the VM. **Low on RAM?** WSL2 is the fallback.
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

## Lessons

1. [Install Ubuntu in a VM](01-install-ubuntu.md)
2. [Finding your way](02-finding-your-way.md)
3. [Working with files](03-working-with-files.md)
4. [Permissions](04-permissions.md)
5. [Packages](05-packages.md)
6. [Services](06-services.md)
7. [Users and groups](07-users-and-groups.md)
8. [Logs and pipes](08-logs-and-pipes.md)
9. [SSH keys](09-ssh.md)
10. [Bash scripting basics](10-bash-scripting.md)
11. [Claude Code in the box](11-claude-code-in-the-box.md)

## Practice

- [Quiz](quiz.md), with the challenge: [OverTheWire Bandit](https://overthewire.org/wargames/bandit/), levels 0–15
- [Project: harden your VM, in a script](project.md): new admin user, SSH keys only, password login off, firewall (`ufw`) on, automatic security updates. Written **by hand**, then by Claude, diffed and reviewed.

## Dig Deeper

- Regex for log hunting
- [The Linux Command Line](https://linuxcommand.org/tlcl.php) by William Shotts (free book)
