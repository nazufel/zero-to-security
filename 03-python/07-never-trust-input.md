# Never trust input

**Pillars:** 🤖 AI

## Why this matters

Whoever types a username, fills in a form, or sends a web request controls that text. Some of them are attackers. **Injection**, number 5 on the [OWASP Top 10:2025](https://owasp.org/Top10/2025/), is what happens when a program treats that text as something it trusts: a command to run, a database query, or a fact.

Security tools aren't immune. A log is full of attacker-written text. A log parser that trusts it can be tricked into blaming the wrong IP address, sending your team after an innocent machine while the real attacker walks away.

## Do it

1. Look at the suspicious line from lesson 5:

   ```bash
   cd ~/my-security-portfolio/python
   grep "02:14:52" auth.log
   ```

   ```
   2026-03-14T02:14:52.774615+00:00 web01 sshd[2450]: Failed password for invalid user admin from 10.0.0.1 port 22 from 198.51.100.23 port 40190 ssh2
   ```

   Read it carefully. There are **two** `from ... port` parts. The attacker at `198.51.100.23` chose the username `admin from 10.0.0.1 port 22`. SSH doesn't care what you type as a username. It writes it into the log as-is.

2. See how a parser gets fooled. In the REPL (`python3`):

   ```python
   >>> line = "Failed password for invalid user admin from 10.0.0.1 port 22 from 198.51.100.23 port 40190 ssh2"
   >>> words = line.split()
   >>> words[words.index("from") + 1]
   '10.0.0.1'
   >>> words[-4]
   '198.51.100.23'
   ```

   "Find the word `from`, take the next word" is a common way to parse this line, and it blames `10.0.0.1`, an internal address. Your own [Module 2 pipeline](../02-linux/08-logs-and-pipes.md) was fooled too:

   ```bash
   grep "Failed password" auth.log | grep -oE "from [0-9.]+" | sort | uniq -c
   ```

   It counts a phantom failure from `10.0.0.1`.

   Reading **from the end** works, because sshd writes the end of the line (`from <ip> port <port> ssh2`) after the username. The attacker controls the middle, not the end.

3. **Validate** that what you extracted is what you expect. Python's built-in `ipaddress` module knows what a real IP looks like:

   ```python
   >>> import ipaddress
   >>> ipaddress.ip_address("198.51.100.23")
   IPv4Address('198.51.100.23')
   >>> ipaddress.ip_address("sshd[2502]:")
   Traceback (most recent call last):
     ...
   ValueError: 'sshd[2502]:' does not appear to be an IPv4 or IPv6 address
   ```

   That's the cut-off line from lesson 5, caught.

4. Put both together in `parse.py`:

   ```python
   # parse.py: pull the IP out of a failed-login line, safely
   import ipaddress


   def failed_login_ip(line):
       """Return the source IP of a failed SSH login line, or None."""
       if "Failed password for " not in line:
           return None
       words = line.split()
       # Trust only the end of the line, which sshd writes:
       # "... from <ip> port <port> ssh2"
       if len(words) < 5 or words[-5] != "from" or words[-3] != "port" or words[-1] != "ssh2":
           return None
       try:
           return str(ipaddress.ip_address(words[-4]))
       except ValueError:
           return None


   counts = {}
   skipped = 0
   with open("auth.log") as log:
       for line in log:
           if "Failed password for " not in line:
               continue
           ip = failed_login_ip(line)
           if ip is None:
               skipped += 1
           else:
               counts[ip] = counts.get(ip, 0) + 1

   print(counts)
   print(f"Skipped {skipped} line(s) that didn't look right")
   ```

   ```bash
   python3 parse.py
   ```

   ```
   {'198.51.100.23': 5, '192.0.2.44': 3, '203.0.113.7': 12, '10.0.2.2': 1}
   Skipped 1 line(s) that didn't look right
   ```

   Correct counts, no phantom IP, no garbage, and the bad line is **counted, not hidden**. `continue` skips to the next line of the loop. This function will go straight into `logslayer`.

## Break it

The same mistake, much worse: trusting input enough to **run** it. Create `lookup.py`:

```python
# lookup.py: DON'T WRITE CODE LIKE THIS
import os

username = input("Username to look up: ")
os.system(f"echo Looking up {username}")
```

```bash
python3 lookup.py
```

Type this as the username:

```text
alice; echo HACKED: this command ran too
```

```
Looking up alice
HACKED: this command ran too
```

`os.system` hands the whole string to the shell, and to the shell, `;` means "and now run another command." The attacker just ran their own command on your server. Swap `echo` for `rm` or `curl` and imagine the damage. That's **command injection**.

The fix: never build a shell command out of strings. Pass a **list**, so the input is only ever data:

```python
import subprocess

username = input("Username to look up: ")
subprocess.run(["echo", "Looking up", username])
```

```
Looking up alice; echo HACKED: this command ran too
```

The `;` is just a character now. Delete `lookup.py` when you're done; it's not a script to keep around.

## With Claude

In `~/my-security-portfolio/python`, start `claude`:

```text
Read parse.py and auth.log. Try to think like an attacker: what could someone
type as an SSH username to make parse.py report the wrong IP, or crash it?
Don't change the file. Give me test lines I can try.
```

**Check the work:** paste each line Claude gives you into a small test, like `print(failed_login_ip("..."))`, and run it. Did any of them actually fool the parser? Remember: an attacker controls only the username. Did Claude write "attack" lines that change parts of the log sshd writes itself, which an attacker can't do? If a real one gets through, you found a bug. Fix it, and note it in your [AI check log](../01-ai-foundations/01-what-ai-is.md).

> **Free AI path:** do this with OpenCode; the prompt is the same.

```bash
git add parse.py
git commit -m "Add safe log parsing"
git push
```

## Check yourself

1. In an SSH log line, which parts can an attacker control?
   <details><summary>Answer</summary>

   The username, and anything else they type. sshd writes the timestamp, the IP, the port, and the structure of the line.
   </details>

2. Why is `os.system(f"ping {host}")` dangerous if `host` comes from a user?
   <details><summary>Answer</summary>

   The shell runs the whole string, so input like `8.8.8.8; rm -rf ~` runs a second command. Use `subprocess.run(["ping", host])` so the input stays data.
   </details>

3. Your parser finds a line it can't make sense of. Skip it silently, crash, or something else?
   <details><summary>Answer</summary>

   Skip it but count it (and ideally report it). Silent skipping hides attacks and bugs; crashing lets one bad line stop the whole analysis.
   </details>

## Go deeper

- [OWASP A05:2025, Injection](https://owasp.org/Top10/2025/): command, SQL, and other injection types, with real examples.
- [OWASP Log Injection](https://owasp.org/www-community/attacks/Log_Injection): attacks on logs and the tools that read them.
