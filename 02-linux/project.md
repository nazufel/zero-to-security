# Project: harden your VM, in a script

**Pillars:** 🪪 Identity · 🤖 AI

## Why this matters

Hardening one server by hand is a lesson. Hardening fifty the same way, every time, takes a script. A hardening script is also proof: a hiring manager can read exactly what you lock down and why. Then you'll have Claude write the same script and compare, which is the job now: AI drafts, you review.

## What to build

```text
my-security-portfolio/
└── linux/
    ├── README.md               # what the scripts do, every line explained
    ├── linux-cheatsheet.md     # from the lessons
    └── scripts/
        ├── check-server.sh     # from lesson 10
        ├── harden.sh           # by hand
        └── harden-claude.sh    # by Claude, reviewed by you
```

`harden.sh` takes a fresh Ubuntu Server and:

1. Installs all updates
2. Creates a new admin user, in the `sudo` group, with your SSH key
3. Turns off SSH password login and root login
4. Turns on the firewall, allowing only SSH
5. Turns on automatic security updates

## New pieces you'll need

You know almost everything already. Here's what's new:

| Piece | What it does |
|---|---|
| `set -euo pipefail` | Stop the script at the first error, instead of carrying on and making things worse |
| `$EUID` | The user ID running the script. Root is `0`. |
| `$1` | The first thing typed after the script's name, like `./harden.sh bob` |
| `$SUDO_USER` | The real user who ran `sudo` |
| `cat > file <<'EOF'` … `EOF` | Writes several lines into a file in one go (a "heredoc") |
| `ufw allow OpenSSH`, `ufw --force enable` | Ubuntu's firewall: allow SSH, then turn it on. **Order matters.** |
| `/etc/apt/apt.conf.d/20auto-upgrades` | The file that turns on automatic security updates (the `unattended-upgrades` package) |

## Steps

1. **Take a snapshot** called `module-2-done`. You'll come back to it.

2. **Write `harden.sh` by hand**, in `~/my-security-portfolio/linux/scripts/`. Use the five steps above as comments, then fill in the commands under each one. Use your cheat sheet, the lessons, and `man`. Don't use AI for this part.

   Before step 3 (SSH), ask: is the new admin's key in place? Before step 4 (firewall), ask: will SSH still be allowed when the firewall turns on? Those two questions are where hardening scripts lock people out.

3. **Test it on a fresh machine.** Restore the `fresh-install` snapshot from lesson 1. Then:

   - From your laptop, copy your key in (password login still works on a fresh install): `ssh-copy-id`, as in [lesson 9](09-ssh.md)
   - In the VM, get your script. Your repo is public, so no login is needed:

     ```bash
     git clone https://github.com/yourname/my-security-portfolio
     cd my-security-portfolio/linux/scripts
     sudo ./harden.sh newadmin
     ```

4. **Prove it worked.** Keep your session open, and from a second laptop terminal:

   ```bash
   ssh newadmin@192.168.64.5                         # works, with your key
   ssh -o PubkeyAuthentication=no newadmin@192.168.64.5  # Permission denied (publickey)
   ```

   (Windows: `-p 2222 newadmin@127.0.0.1`.) Then, in the VM:

   ```bash
   sudo sshd -T | grep -iE "passwordauthentication|permitrootlogin"
   sudo ufw status
   groups newadmin
   cat /etc/apt/apt.conf.d/20auto-upgrades
   ```

   Run the script a **second time**. Does it still work, or does it crash because the user already exists? A good hardening script can run twice safely.

   Didn't work? Restore `fresh-install` and try again. That's what it's for.

5. **Restore `module-2-done`** to get back to where you were.

6. **Have Claude write one.** In Claude Code in the VM (or [claude.ai](https://claude.ai)), give it the same five requirements, word for word, and ask for `harden-claude.sh`. Save it next to yours, then compare:

   ```bash
   diff -u harden.sh harden-claude.sh
   ```

7. **Review Claude's script line by line.** Check for each of these, and note what you find:

   - [ ] Does it enable the firewall *before* allowing SSH? (Lockout.)
   - [ ] Does it turn off passwords *before* the new user has a key? (Lockout.)
   - [ ] Does it put its SSH settings in a file that an existing `50-` file could override? ([Lesson 9](09-ssh.md))
   - [ ] Does it run `sshd -t` before restarting SSH?
   - [ ] Any `usermod -G` without `-a`? ([Lesson 7](07-users-and-groups.md))
   - [ ] Any hard-coded passwords, `chmod 777`, or `curl ... | bash`?
   - [ ] Anything it does that you didn't ask for?

   Did Claude do something better than you? Say so. That's part of an honest review.

8. **Write `linux/README.md`.** Explain what each script does, then go through `harden.sh` and explain every line in plain English. Add a short section called **"Claude's version vs. mine"** with what your review found.

9. **Commit and push**, and add the project to your portfolio's main README table:

   ```bash
   git add linux/
   git commit -m "Add VM hardening scripts and review"
   git push
   ```

<details><summary>One working <code>harden.sh</code> (only open this after you've written yours)</summary>

```bash
#!/usr/bin/env bash
# harden.sh: lock down a fresh Ubuntu Server
# Usage: sudo ./harden.sh <new-admin-username>
set -euo pipefail

new_admin="${1:?Usage: sudo ./harden.sh <new-admin-username>}"

if [[ $EUID -ne 0 ]]; then
  echo "Run this with sudo." >&2
  exit 1
fi

# 1. Install all updates
apt-get update
apt-get -y upgrade

# 2. New admin user, in sudo, with the same SSH key as the person running this
if ! id "$new_admin" &>/dev/null; then
  adduser --disabled-password --comment "" "$new_admin"
  echo "Set a password for $new_admin (needed for sudo):"
  passwd "$new_admin"
fi
usermod -aG sudo "$new_admin"
install -d -m 700 -o "$new_admin" -g "$new_admin" "/home/$new_admin/.ssh"
install -m 600 -o "$new_admin" -g "$new_admin" \
  "/home/$SUDO_USER/.ssh/authorized_keys" "/home/$new_admin/.ssh/authorized_keys"

# 3. SSH: keys only, no root. 01- so it wins over any 50- file.
cat > /etc/ssh/sshd_config.d/01-hardening.conf <<'EOF'
PasswordAuthentication no
KbdInteractiveAuthentication no
PermitRootLogin no
EOF
sshd -t
systemctl restart ssh

# 4. Firewall: allow SSH first, then turn it on
ufw allow OpenSSH
ufw --force enable

# 5. Automatic security updates
apt-get install -y unattended-upgrades
cat > /etc/apt/apt.conf.d/20auto-upgrades <<'EOF'
APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Unattended-Upgrade "1";
EOF

echo "Done. Test SSH as $new_admin from a NEW terminal before closing this one."
```

Yours doesn't have to match. If it passes every check in step 4, it works.
</details>

## Done when

- [ ] `harden.sh` turns `fresh-install` into a hardened server, and you've proven each step from a second terminal
- [ ] It runs twice without breaking
- [ ] `harden-claude.sh` is reviewed against the checklist, and your findings are in the README
- [ ] You can explain every line of `harden.sh` without reading the README

This is the first real project in your portfolio. Interviewers will ask about it, especially "what happened when you locked yourself out?" Have that story ready.
