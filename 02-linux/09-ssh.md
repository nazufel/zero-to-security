# SSH keys

**Pillars:** 🪪 Identity

## Why this matters

In the last lesson you guessed passwords against your own server, and the logs showed how easy it is. Real attackers do this all day, to every SSH server on the internet, with lists of millions of leaked passwords. A weak or reused password is eventually guessed.

**SSH keys** fix that. A key is a pair of files: a **private key** that never leaves your laptop, and a **public key** you put on the server. Nothing guessable crosses the network. Then you turn password login off, and the guessing stops mattering.

## Do it

1. **On your laptop**, make a key pair:

   ```bash
   ssh-keygen -t ed25519 -C "laptop to lab VM"
   ```

   Press Enter to accept the default location. **Set a passphrase** when asked. If someone steals your laptop, the passphrase is what stops them from using the key.

   ```bash
   ls -l ~/.ssh
   ```

   ```
   -rw-------  1 you  staff  464 Mar 14 02:40 id_ed25519
   -rw-r--r--  1 you  staff   98 Mar 14 02:40 id_ed25519.pub
   ```

   `id_ed25519` is private: `600`, only you. `id_ed25519.pub` is public: safe to share. Lesson 4 just paid off.

2. Give the server your **public** key.

   **Mac:**

   ```bash
   ssh-copy-id yourusername@192.168.64.5
   ```

   **Windows (Git Bash):**

   ```bash
   cat ~/.ssh/id_ed25519.pub | ssh -p 2222 yourusername@127.0.0.1 "mkdir -p ~/.ssh && chmod 700 ~/.ssh && cat >> ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys"
   ```

   Type your VM password one last time. Your public key is now in `~/.ssh/authorized_keys` on the VM: the list of keys allowed to log in as you.

3. Make a shortcut. **On your laptop**, create or edit `~/.ssh/config`:

   ```text
   Host lab
       HostName 192.168.64.5
       User yourusername
   ```

   On Windows, use `HostName 127.0.0.1` and add a line `    Port 2222`.

   ```bash
   ssh lab
   ```

   It asks for your key's **passphrase**, not your VM password. You're in. From now on, `ssh lab` is all you type.

4. **Take a snapshot.** The next step can lock you out.

5. **In the VM**, turn off password login. Ubuntu reads extra SSH settings from files in `/etc/ssh/sshd_config.d/`. Make your own:

   ```bash
   sudo nano /etc/ssh/sshd_config.d/01-hardening.conf
   ```

   ```text
   PasswordAuthentication no
   KbdInteractiveAuthentication no
   PermitRootLogin no
   ```

   Passwords off, the other password-style login off, and root can't log in over SSH at all.

6. Test the config, then check what SSH will *actually* use:

   ```bash
   sudo sshd -t
   sudo sshd -T | grep -iE "passwordauthentication|kbdinteractive|permitrootlogin"
   ```

   `sshd -t` prints nothing if the config is valid. `sshd -T` prints the final settings:

   ```
   permitrootlogin no
   passwordauthentication no
   kbdinteractiveauthentication no
   ```

7. Apply it, **but keep this session open**:

   ```bash
   sudo systemctl restart ssh
   ```

8. **Open a second terminal** on your laptop and test:

   ```bash
   ssh lab
   ```

   Key login still works. Now prove passwords are dead:

   ```bash
   ssh -o PubkeyAuthentication=no lab
   ```

   ```
   yourusername@192.168.64.5: Permission denied (publickey).
   ```

   The server won't even ask for a password. Only now is it safe to close your first session.

> **The rule for every remote change:** keep one session open, test in a second one. If the change locked you out, the open session is how you fix it.

## Break it

SSH settings have a trap that catches experienced engineers. Many installers and cloud images drop their own file into `sshd_config.d/`. On cloud servers it's usually called `50-cloud-init.conf`. Simulate one:

```bash
echo "PasswordAuthentication yes" | sudo tee /etc/ssh/sshd_config.d/50-installer.conf
sudo mv /etc/ssh/sshd_config.d/01-hardening.conf /etc/ssh/sshd_config.d/99-hardening.conf
sudo sshd -T | grep -i passwordauthentication
```

What you should see:

```
passwordauthentication yes
```

Your file still says `no`. But SSH reads these files in alphabetical order and **the first value it finds wins**. `50-` comes before `99-`, so passwords are back on. If you'd only read your own file, you'd swear passwords were off.

Put it right:

```bash
sudo mv /etc/ssh/sshd_config.d/99-hardening.conf /etc/ssh/sshd_config.d/01-hardening.conf
sudo rm /etc/ssh/sshd_config.d/50-installer.conf
sudo sshd -T | grep -i passwordauthentication
```

Back to `no`. **Check what the system actually does, not what your file says.** `sshd -T` is how. Run `ls /etc/ssh/sshd_config.d/` on any server you manage. A file like `50-cloud-init.conf` is often really there.

## With Claude

Ask [claude.ai](https://claude.ai):

```text
How do I disable SSH password login on Ubuntu Server 26.04?
```

**Check the work:** three things.

- Does it edit the main `sshd_config` file, or add a file in `sshd_config.d/`? Either can work, but does it mention that files in `sshd_config.d/` can override it?
- If it creates a file there, what's the name? A `99-` name loses to an existing `50-` file, as you just saw.
- Does it tell you to keep a session open and test before logging out? If not, it just handed you a lockout.

Then verify any answer the only way that counts: `sudo sshd -T`.

## Check yourself

1. Which half of your key pair goes on the server?
   <details><summary>Answer</summary>

   The public key (`.pub`). The private key never leaves your laptop.
   </details>

2. You disabled password login, and your file says `PasswordAuthentication no`. How do you prove it's really off?
   <details><summary>Answer</summary>

   `sudo sshd -T | grep -i passwordauthentication` shows the setting SSH actually uses. Then test from a second terminal with `ssh -o PubkeyAuthentication=no`, which should be refused.
   </details>

3. Why keep your first SSH session open while you test?
   <details><summary>Answer</summary>

   If the change broke login, the open session is your only way back in to fix it.
   </details>

## Go deeper

- [Ubuntu: OpenSSH server](https://documentation.ubuntu.com/server/how-to/security/openssh-server/): the official guide, including more hardening options.
- [Mozilla's OpenSSH guidelines](https://infosec.mozilla.org/guidelines/openssh): the settings a real security team uses.
