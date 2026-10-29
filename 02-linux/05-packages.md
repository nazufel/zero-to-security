# Packages

## Why this matters

In 2017, attackers broke into Equifax through a known bug in Apache Struts, web software the company ran. A fix had been out for two months. Nobody had installed it. The personal data of about 147 million people was stolen.

Most breaches don't need a clever new attack. They use an old bug that someone didn't patch. On Ubuntu, patching is two commands. Knowing them, and running them, is a security skill.

## Do it

1. Refresh the list of available software:

   ```bash
   sudo apt update
   ```

   This doesn't install anything. It downloads the latest catalog from Ubuntu's servers so your system knows what's new. At the end it tells you how many packages can be upgraded.

2. See what's out of date:

   ```bash
   apt list --upgradable
   ```

3. Install the updates:

   ```bash
   sudo apt upgrade -y
   ```

   `-y` answers "yes" to the confirmation. If the output mentions a restart is required, run `sudo reboot` and SSH back in after a minute.

4. Install new software. **apt** is Ubuntu's **package manager**: it downloads software from Ubuntu's trusted servers, checks it, and installs it with everything it depends on.

   ```bash
   sudo apt install -y tree gh
   tree ~/lab
   ```

   What you should see, roughly:

   ```
   /home/yourusername/lab
   ├── hello.sh
   ├── hello.txt
   ├── notes
   │   └── linux-cheatsheet.md
   └── secret.txt
   ```

5. Look before you install. Every package is code you're choosing to trust:

   ```bash
   apt show tree
   ```

   Who maintains it, what it depends on, and what it does. You'll take this idea much further in Module 3 (Python packages) and Module 5 (container images).

6. Remove something you don't need:

   ```bash
   sudo apt remove -y tree
   ```

   Less software means fewer things to patch and fewer things to attack.

7. Get your portfolio into the VM. You'll commit your Linux work from here. Log in to GitHub like you did in [Module 0](../00-start-here/03-git-and-github.md):

   ```bash
   gh auth login
   ```

   Choose **GitHub.com → HTTPS → Yes → Login with a web browser**. The VM has no browser, so open the link it shows on your laptop and enter the code. Then set your name and noreply email, and clone your repo:

   ```bash
   git config --global user.name "Your Name"
   git config --global user.email "12345678+yourname@users.noreply.github.com"
   gh repo clone my-security-portfolio ~/my-security-portfolio
   ```

8. Move your cheat sheet in and commit it:

   ```bash
   mkdir -p ~/my-security-portfolio/linux
   mv ~/lab/notes/linux-cheatsheet.md ~/my-security-portfolio/linux/
   cd ~/my-security-portfolio
   git add linux/linux-cheatsheet.md
   git commit -m "Add Linux cheat sheet"
   git push
   ```

   From now on, your cheat sheet lives at `~/my-security-portfolio/linux/linux-cheatsheet.md`. Keep adding to it.

> **Notice:** your GitHub login now lives in this VM. Anything that runs in the VM, including an AI agent, can push to your repos. You'll come back to this in lesson 11.

## Break it

Forget `sudo`:

```bash
apt install tree
```

What you should see:

```
E: Could not open lock file /var/lib/dpkg/lock-frontend - open (13: Permission denied)
E: Unable to acquire the dpkg frontend lock (/var/lib/dpkg/lock-frontend), are you root?
```

The last line says it plainly: *are you root?* Installing software changes the whole system, so only an admin can do it. That's good. If any user could install software, so could any attacker who got into any account.

Now a typo:

```bash
sudo apt install nginxx
```

```
E: Unable to locate package nginxx
```

apt only installs what's in the catalog. That protects you from typos, but not from everything. In Module 3 you'll meet package managers where a typo can install an attacker's package.

## With Claude

```bash
apt list --upgradable
```

If the list is empty, run `apt list --installed | head -30` instead. Paste the output into [claude.ai](https://claude.ai):

```text
These are packages on my Ubuntu server. Which ones would matter most from a
security point of view if they were out of date, and why?
```

**Check the work:** for any package Claude says is security-critical, run `apt show <package>` and read the description. Does it actually do what Claude said? Did Claude mention a specific vulnerability? If so, look it up. AI often attaches real-sounding CVE numbers to the wrong software.

## Check yourself

1. What's the difference between `apt update` and `apt upgrade`?
   <details><summary>Answer</summary>

   `update` refreshes the list of what's available. `upgrade` installs the newer versions. You need both, in that order.
   </details>

2. Why does `apt install` need `sudo`?
   <details><summary>Answer</summary>

   Installing software changes the whole system, so only admins can do it. Otherwise any compromised account could install malware system-wide.
   </details>

3. Why remove packages you don't use?
   <details><summary>Answer</summary>

   Every package is something to patch and something an attacker might exploit. Less software means a smaller attack surface.
   </details>

## Go deeper

- [Ubuntu Security Notices](https://ubuntu.com/security/notices): every security fix Ubuntu ships, with the CVEs it fixes. This is what `apt upgrade` is installing.
