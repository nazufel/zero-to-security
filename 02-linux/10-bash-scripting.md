# Bash scripting basics

## Why this matters

Anything you type twice, you'll eventually type wrong. A script is a file of commands that runs the same way every time. It's also a record: six months from now, you, a teammate, or an auditor can read exactly what was done to a server.

This lesson's script is the warm-up for the module project, where you'll script the hardening you did by hand.

## Do it

1. Make a place for scripts in your portfolio:

   ```bash
   mkdir -p ~/my-security-portfolio/linux/scripts
   cd ~/my-security-portfolio/linux/scripts
   nano check-server.sh
   ```

2. Type this in yourself. Don't paste it. Typing is how it sticks.

   ```bash
   #!/usr/bin/env bash
   # check-server.sh: a quick health and security check for my lab VM

   echo "== $(hostname) at $(date) =="

   echo
   echo "Disk usage:"
   df -h /

   echo
   echo "Services:"
   for service in ssh cron unattended-upgrades; do
     status=$(systemctl is-active "$service")
     echo "  $service: $status"
   done

   echo
   failed=$(journalctl -u ssh --since today | grep -c "Failed password")
   echo "Failed SSH passwords today: $failed"
   ```

   Line by line:

   | Line | What it does |
   |---|---|
   | `#!/usr/bin/env bash` | The "shebang": tells Linux to run this file with Bash |
   | `# ...` | A comment. Bash ignores it. People don't. |
   | `$(hostname)` | Runs a command and puts its output right here |
   | `for service in ...; do ... done` | A **loop**: runs the inside once for each word in the list |
   | `status=$(...)` | A **variable**: saves a value under a name. No spaces around `=`. |
   | `"$service"` | Uses the variable. The quotes keep it safe if the value has spaces. |
   | `grep -c` | Counts matching lines, instead of printing them |

3. Make it executable and run it:

   ```bash
   chmod 755 check-server.sh
   sudo ./check-server.sh
   ```

   It needs `sudo` to read the SSH journal. What you should see (yours will differ):

   ```
   == lab at Sat Mar 14 02:51:07 UTC 2026 ==

   Disk usage:
   Filesystem      Size  Used Avail Use% Mounted on
   /dev/sda2        24G  4.1G   19G  19% /

   Services:
     ssh: active
     cron: active
     unattended-upgrades: active

   Failed SSH passwords today: 3
   ```

4. Commit it:

   ```bash
   git add check-server.sh
   git commit -m "Add server check script"
   git push
   ```

## Break it

The most common Bash mistake. Open the script and add spaces around one `=`:

```bash
failed = $(journalctl -u ssh --since today | grep -c "Failed password")
```

Run it:

```bash
sudo ./check-server.sh
```

```
./check-server.sh: line 18: failed: command not found
```

With spaces, Bash thinks `failed` is a command you want to run, with `=` as its first argument. Variable assignment means **no spaces**. Put it back.

Now see why the quotes matter. At the prompt:

```bash
file="my notes.txt"
touch "$file"
ls $file
```

```
ls: cannot access 'my': No such file or directory
ls: cannot access 'notes.txt': No such file or directory
```

Without quotes, Bash splits the value at the space and treats it as two files. Now try `ls "$file"`. It works. Imagine that was `rm $file` instead of `ls`: it would try to delete two files you never meant to touch. Quoting your variables prevents a whole family of bugs, some of them security bugs. Clean up with `rm "$file"`.

## With Claude

Ask [claude.ai](https://claude.ai), pasting your script:

```text
Here's my Bash script. Add a check that prints how many package updates are
waiting to be installed. Keep my style, and explain each new line.
```

**Check the work:** before you run its version:

- Read every new line. Can you explain each one? If not, ask.
- Does the new check need `sudo` or change anything on the system? A *check* script should only read, never change. If Claude added `apt upgrade`, that's a different script.
- Run it. Then compare the count it prints against `apt list --upgradable`. Do they match?

If it works and you understand it, commit it. If not, add an entry to your [AI check log](../01-ai-foundations/01-what-ai-is.md).

## Check yourself

1. What's wrong with `name = "alice"` in Bash?
   <details><summary>Answer</summary>

   The spaces. Bash reads it as running a command called `name`. It must be `name="alice"`.
   </details>

2. What does `for f in a b c; do echo "$f"; done` print?
   <details><summary>Answer</summary>

   `a`, `b`, and `c`, each on its own line. The loop runs once per word.
   </details>

3. Why quote variables, like `"$file"` instead of `$file`?
   <details><summary>Answer</summary>

   Without quotes, a value with spaces is split into several words, so `rm $file` on `my notes.txt` tries to delete `my` and `notes.txt`. Quotes keep it as one value.
   </details>

## Go deeper

- [ShellCheck](https://www.shellcheck.net/): paste any Bash script and it finds bugs like unquoted variables. Free, and also installable with `sudo apt install shellcheck`. Run it on Claude's scripts too.
