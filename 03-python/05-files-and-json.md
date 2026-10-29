# Files and JSON

**Pillars:** 🤖 AI

## Why this matters

Security work is reading files and writing reports. Logs come in as text. Results go out as **JSON**, the format almost every security tool, cloud API, and dashboard speaks. When `logslayer` reports to another program instead of a human (Module 9), it'll speak JSON.

## Do it

1. Get a realistic log to work with. This one's from a made-up web server, `web01`, on a bad night:

   ```bash
   cd ~/my-security-portfolio/python
   curl -fsSL -o auth.log https://raw.githubusercontent.com/nazufel/zero-to-security/main/03-python/samples/auth.log
   wc -l auth.log
   less auth.log
   ```

   Skim it. You'll recognize the format from [Module 2](../02-linux/08-logs-and-pipes.md).

2. Read it with Python. Create `read_log.py`:

   ```python
   # read_log.py: count failed logins per IP from a log file
   import json

   counts = {}
   with open("auth.log") as log:
       for line in log:
           if "Failed password" in line:
               words = line.split()
               ip = words[-4]
               counts[ip] = counts.get(ip, 0) + 1

   print(counts)

   with open("report.json", "w") as out:
       json.dump(counts, out, indent=2)
   ```

   - `with open(...) as log:` opens the file and closes it automatically when the block ends.
   - `for line in log:` reads one line at a time, so even a huge log doesn't fill your memory.
   - `import json` loads Python's built-in JSON module. No install needed.
   - `open("report.json", "w")` opens a file for **w**riting.

3. Run it:

   ```bash
   python3 read_log.py
   ```

   ```
   {'198.51.100.23': 5, '192.0.2.44': 3, '203.0.113.7': 12, 'sshd[2502]:': 1, '10.0.2.2': 1}
   ```

   Four IP addresses, and one thing that isn't an IP at all: `sshd[2502]:`. Find that line in `auth.log` (`grep 2502 auth.log`). It got cut off. Hold that thought; it's the subject of [lesson 7](07-never-trust-input.md).

4. Look at the report:

   ```bash
   cat report.json
   ```

   ```json
   {
     "198.51.100.23": 5,
     "192.0.2.44": 3,
     "203.0.113.7": 12,
     "sshd[2502]:": 1,
     "10.0.2.2": 1
   }
   ```

   JSON looks almost exactly like a Python dictionary. That's why it's so easy to work with.

5. Read JSON back in. In the REPL (`python3`):

   ```python
   >>> import json
   >>> with open("report.json") as f:
   ...     report = json.load(f)
   ...
   >>> type(report)
   <class 'dict'>
   >>> report["203.0.113.7"]
   12
   ```

   `json.dump` writes a dictionary to a file. `json.load` reads it back. Type `exit()` to leave.

## Break it

Opening a file for writing **empties it first**, before you've written a single byte. Make a copy of the log to sacrifice:

```bash
cp auth.log evidence.log
wc -l evidence.log
python3 -c 'open("evidence.log", "w")'
wc -l evidence.log
```

What you should see:

```
38 evidence.log
0 evidence.log
```

One line of Python, and the evidence is gone. It's the same mistake as `>` instead of `>>` in [Module 2](../02-linux/03-working-with-files.md), in a new language. `"w"` replaces, `"a"` appends, and `"r"` (the default) only reads. When your code touches logs, open them read-only, and write reports to a *different* file.

```bash
rm evidence.log
```

## With Claude

In `~/my-security-portfolio/python`, start `claude`:

```text
Read read_log.py and auth.log. Without changing anything, tell me why
'sshd[2502]:' ended up in the counts, and whether any of the other counts
might also be wrong.
```

**Check the work:** check each claim against `auth.log` yourself with `grep`. Claude should spot the cut-off line. Does it notice anything about the line from `198.51.100.23` at 02:14:52? Look at it closely. Is the username normal? Whether or not Claude catches it, you'll come back to it in lesson 7.

> **Free AI path:** do this with OpenCode; the prompt is the same.

Don't commit `auth.log` or `report.json` here; they're practice data. Commit the script:

```bash
git add read_log.py
git commit -m "Add log reading script"
git push
```

## Check yourself

1. What's the difference between `open(path)`, `open(path, "w")`, and `open(path, "a")`?
   <details><summary>Answer</summary>

   Read only (the default), write (empties the file first), and append (adds to the end).
   </details>

2. Why use `with open(...) as f:` instead of plain `open()`?
   <details><summary>Answer</summary>

   It closes the file automatically when the block ends, even if an error happens inside it.
   </details>

3. What do `json.dump` and `json.load` do?
   <details><summary>Answer</summary>

   `dump` writes Python data (like a dictionary) to a file as JSON. `load` reads JSON from a file back into Python data.
   </details>

## Go deeper

- [Python tutorial: reading and writing files](https://docs.python.org/3/tutorial/inputoutput.html#reading-and-writing-files): file modes and the `json` module.
