# Install Ubuntu in a VM

## Why this matters

You're about to break things on purpose: lock yourself out, delete files, misconfigure services. You need a computer where that's safe. A **virtual machine (VM)** is a whole computer running as software inside your real one. If you wreck it, you roll it back in a minute, and your laptop never notices.

The VM is also the first box from [Module 1](../01-ai-foundations/05-ai-in-a-box.md). When you install Claude Code in lesson 11, it goes here, not on your laptop.

## Do it

> **Last verified:** 2026-10-29. Ubuntu Server **26.04 LTS** is the current long-term support release. UTM 5 added snapshots for Mac. If a newer LTS is out, use it; the steps barely change.

### 1. Download Ubuntu Server

| Your laptop | Download |
|---|---|
| Mac with Apple Silicon (M1 or newer) | [Ubuntu Server for ARM](https://ubuntu.com/download/server/arm) |
| Intel Mac or Windows | [Ubuntu Server](https://ubuntu.com/download/server) |

Not sure which Mac you have? Apple menu → **About This Mac**. "Chip: Apple M…" means Apple Silicon.

### 2. Create the VM

Give it **2 CPUs**, **4 GB of memory** (2 GB if your laptop only has 8 GB), and a **25 GB disk**. Name it `lab`.

**Mac: [UTM](https://mac.getutm.app/)** (free from the website)

1. **Create a New Virtual Machine → Virtualize → Linux.**
2. Under **Boot ISO Image**, browse to the file you downloaded.
3. Set memory, CPUs, and disk as above. Skip the shared directory.
4. Name it `lab`, save, and press ▶️ to start it.

**Windows: [VirtualBox](https://www.virtualbox.org/)** (free, works on Windows Home)

1. **New.** Name it `lab`, pick the ISO you downloaded.
2. Turn **unattended installation off**. The wording of the checkbox varies by version. You want to see the installer yourself.
3. Set memory, CPUs, and disk as above, and finish.
4. Before you start it: **Settings → Network → Adapter 1 → Port Forwarding** (switch Settings to Expert mode if you don't see it). Add one rule: protocol `TCP`, host IP `127.0.0.1`, host port `2222`, guest port `22`. This lets your laptop reach the VM over SSH.
5. Start it.

> **Low on RAM?** WSL2 on Windows runs Ubuntu without a full VM. It works for most of this module, but snapshots and some service steps differ. Use it only if a VM won't run.

### 3. Run the installer

Use the arrow keys, Space, and Enter. Take the defaults except for these:

- **Profile:** your name, server name `lab`, a username, and a strong password you'll remember. You'll type it a lot.
- **Ubuntu Pro:** skip for now.
- **SSH:** check **Install OpenSSH server**. Don't import any keys.
- **Featured snaps:** select none.

When it finishes, it asks you to remove the install media. In UTM, clear the CD/DVD drive from the toolbar. VirtualBox usually does it for you. Then press Enter to reboot.

### 4. Log in and update

Log in at the `lab login:` prompt. Then:

```bash
sudo apt update && sudo apt upgrade -y
```

`sudo` asks for your password. Nothing appears as you type it. That's normal. You'll learn what this command does in lesson 5.

### 5. Connect from your laptop

The VM window is clumsy: no copy and paste, tiny text. From now on you'll work from your laptop's terminal over **SSH** (Secure Shell), an encrypted remote login.

**Mac:** find the VM's address. In the VM:

```bash
ip -brief address
```

What you should see (your numbers will differ):

```
lo               UNKNOWN        127.0.0.1/8 ::1/128
enp0s1           UP             192.168.64.5/24 fdxx::xxxx/64
```

The address that starts with `192.168` is your VM. On your Mac:

```bash
ssh yourusername@192.168.64.5
```

**Windows (Git Bash):** use the port forward you set up:

```bash
ssh -p 2222 yourusername@127.0.0.1
```

The first time, SSH asks if you trust this host. Type `yes`. Then enter your VM password. Your prompt changes to `yourusername@lab:~$`. You're in.

### 6. Take your first snapshot

A **snapshot** saves the VM's exact state so you can return to it later.

1. In the VM, shut it down cleanly:

   ```bash
   sudo poweroff
   ```

2. **UTM:** open the VM's **Snapshots** tab and save one. **VirtualBox:** select the VM → **Snapshots** → **Take**.
3. Name it `fresh-install`.
4. Start the VM again and SSH back in.

**The habit:** take a snapshot before anything risky. Every lesson that could lock you out will remind you.

## Break it

Prove the snapshot works. In the VM, delete something you need:

```bash
sudo rm /usr/bin/nano
nano
```

What you should see:

```
Command 'nano' not found, but can be installed with:
sudo apt install nano
```

The text editor is gone. Now power off and **restore** the `fresh-install` snapshot (UTM: Snapshots tab → restore; VirtualBox: Snapshots → Restore). Start it, SSH in, and run `nano`. It's back. Press `Ctrl+X` to quit.

That's the safety net for the rest of the course. Real servers don't have one this easy, which is why you practice here.

## With Claude

Run this in the VM and paste the output into [claude.ai](https://claude.ai):

```bash
hostnamectl
```

```text
I just installed Ubuntu Server in a VM. Explain each line of this output.
Which lines would matter to a security person, and why?
```

**Check the work:** does Claude's version of the OS and kernel match what's actually on your screen, or did it "fill in" a version from memory? You know the real answer. It's right in front of you.

## Check yourself

1. Why do this course in a VM instead of directly on your laptop?
   <details><summary>Answer</summary>

   You can break it and roll back with a snapshot, and anything that goes wrong (including AI running commands) is boxed into the VM instead of your real machine.
   </details>

2. You're about to try something that might lock you out. What do you do first?
   <details><summary>Answer</summary>

   Take a snapshot. If it goes wrong, you restore in a minute instead of reinstalling.
   </details>

3. Why work over SSH from your laptop instead of in the VM window?
   <details><summary>Answer</summary>

   Copy and paste work, the text is readable, and it's how you'll reach every real server you ever manage. Nobody walks up to a cloud server's keyboard.
   </details>

## Go deeper

- [Ubuntu Server documentation](https://documentation.ubuntu.com/server/): the official docs. The "Tutorials" section covers everything in this module from Canonical's side.
