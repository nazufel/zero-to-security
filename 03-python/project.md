# Project: `logslayer`

**Pillars:** 🤖 AI

## Why this matters

`logslayer` is a real security tool: it reads a server's login log and shows who's trying to get in. You'll build it by hand first, so you understand every line. Then you'll extend it with Claude, so you practice the job as it's done now: AI writes, you review.

It's also the tool you'll keep for the rest of the course. It gets containerized in Module 5, learns to read AWS CloudTrail in Module 6, and gets a detection mode in Module 9.

## What to build

```text
my-security-portfolio/
└── logslayer/
    ├── CLAUDE.md               # lesson 12
    ├── README.md               # what it does, how to run it, what you learned
    ├── pyproject.toml
    ├── uv.lock
    ├── samples/
    │   └── auth.log            # the sample log from lesson 5
    ├── src/
    │   └── logslayer/
    │       └── __init__.py
    └── tests/
        └── test_parse.py
```

## Part 1: v1, by hand

**Do this after [lesson 11](11-testing.md), before lesson 12.** No AI for this part. Use your lessons, your cheat sheet, and the [Python docs](https://docs.python.org/3/).

### The spec

```bash
uv run logslayer samples/auth.log
```

```
Failed SSH logins by IP in samples/auth.log
  203.0.113.7         12
  198.51.100.23        5
  192.0.2.44           3
  10.0.2.2             1
Skipped 1 line(s) that couldn't be parsed
```

v1 must:

1. Take the log file path as an argument, with `argparse` (lesson 10)
2. Count failed logins per IP with your `failed_login_ip` (lessons 4, 7)
3. Print the report sorted worst first (lesson 4)
4. Count lines that look like failed logins but can't be parsed, and report them (lesson 7)
5. Handle a missing file and a permission error with a clear message and exit code 1, never a traceback (lesson 6)
6. Keep your tests from lesson 11 passing

### Steps

1. Copy the sample log into the project:

   ```bash
   cd ~/my-security-portfolio/logslayer
   mkdir -p samples
   cp ../python/auth.log samples/
   ```

2. In `src/logslayer/__init__.py`, write a `count_failures(lines)` function and replace uv's `main()` with yours. Hint: `count_failures` can take an open file, because looping over a file gives you its lines.

3. Test it against the spec:

   ```bash
   uv run logslayer samples/auth.log
   uv run logslayer missing.log; echo "exit code: $?"
   uv run logslayer
   uv run pytest
   ```

   Your report should match the spec exactly. `missing.log` should print one clear line and exit code 1. With no argument, argparse should print usage.

4. Run it on your VM's real log too:

   ```bash
   uv run logslayer /var/log/auth.log
   sudo .venv/bin/logslayer /var/log/auth.log
   ```

   The first should tell you, politely, to use sudo. (`sudo uv run` usually can't find `uv`, so the second line runs the tool from the project's environment directly.)

5. Commit:

   ```bash
   git add .
   git commit -m "logslayer v1"
   git push
   ```

<details><summary>One working v1 (only open this after yours works, or after you've been stuck for 20 minutes)</summary>

```python
"""logslayer: report failed SSH logins by IP address."""

import argparse
import ipaddress
import sys


def failed_login_ip(line):
    """Return the source IP of a failed SSH login line, or None."""
    if "Failed password for " not in line:
        return None
    words = line.split()
    # Trust only the end of the line, which sshd writes:
    # "... from <ip> port <port> ssh2". The username is typed by the attacker.
    if len(words) < 5 or words[-5] != "from" or words[-3] != "port" or words[-1] != "ssh2":
        return None
    try:
        return str(ipaddress.ip_address(words[-4]))
    except ValueError:
        return None


def count_failures(lines):
    """Count failed logins per IP. Return (counts, number of lines skipped)."""
    counts = {}
    skipped = 0
    for line in lines:
        if "Failed password for " not in line:
            continue
        ip = failed_login_ip(line)
        if ip is None:
            skipped += 1
        else:
            counts[ip] = counts.get(ip, 0) + 1
    return counts, skipped


def main():
    parser = argparse.ArgumentParser(description="Report failed SSH logins by IP address.")
    parser.add_argument("logfile", help="path to an auth.log file")
    args = parser.parse_args()

    try:
        with open(args.logfile) as log:
            counts, skipped = count_failures(log)
    except FileNotFoundError:
        print(f"logslayer: no such file: {args.logfile}", file=sys.stderr)
        sys.exit(1)
    except PermissionError:
        print(f"logslayer: permission denied: {args.logfile} (try sudo)", file=sys.stderr)
        sys.exit(1)

    print(f"Failed SSH logins by IP in {args.logfile}")
    for ip in sorted(counts, key=counts.get, reverse=True):
        print(f"  {ip:<18}{counts[ip]:>4}")
    if skipped:
        print(f"Skipped {skipped} line(s) that couldn't be parsed")
```

`{ip:<18}` pads the IP to 18 characters, left-aligned. `{counts[ip]:>4}` right-aligns the count in 4. Yours doesn't need to match line for line. If it meets the spec and the tests pass, it works.
</details>

Now do [lesson 12](12-building-with-claude-code.md).

## Part 2: v2, with Claude

Use Claude Code with your `CLAUDE.md`, Plan mode first, and review every diff, exactly as in lesson 12. Add three features, **one at a time**, with a commit after each:

1. **`--top N`:** show only the N worst IPs. `--top 2` on the sample shows `203.0.113.7` and `198.51.100.23`.
2. **`--json`:** print the report as JSON instead of text, so other tools can read it:

   ```json
   {
     "logfile": "samples/auth.log",
     "failures": {"203.0.113.7": 12, "198.51.100.23": 5, "192.0.2.44": 3, "10.0.2.2": 1},
     "skipped": 1
   }
   ```

3. **Tests** for both features, including what happens with `--top 0`, `--top -1`, and `--top` larger than the number of IPs.

### Review every change against this list

- [ ] You can explain every changed line
- [ ] `git diff` shows only what you asked for
- [ ] No new dependencies in `pyproject.toml`
- [ ] No `eval`, `exec`, `os.system`, or `shell=True`
- [ ] No existing test was changed or deleted to make it pass
- [ ] You ran `uv run pytest` yourself, and each new test fails if you break the feature it tests
- [ ] `--top -1` is rejected with a clear error, not silently accepted (lesson 7: never trust input, even your own flags)
- [ ] `--json` output is valid JSON. Check with `uv run logslayer samples/auth.log --json | python3 -m json.tool`

Anything that fails the list goes back to Claude with what's wrong and why.

### Write the README

Replace uv's empty `logslayer/README.md` with:

- What `logslayer` does, in two sentences
- How to install and run it, with example output
- **How it handles attacker-controlled input:** the spoofed-username attack, and how the parser avoids it
- **Built with Claude:** what you built by hand, what Claude built, and one thing you caught in review

Then add `logslayer` to your portfolio's main README table, and commit.

## Done when

- [ ] `uv run logslayer samples/auth.log` matches the spec, and `--top` and `--json` work
- [ ] Missing files and permission errors give a clear message and exit code 1
- [ ] `uv run pytest` passes, with a test for the spoofed-username attack
- [ ] Every Claude change was reviewed against the checklist
- [ ] The README explains how it handles attacker-controlled input
- [ ] You can explain every line in `src/logslayer/__init__.py` without looking anything up

In an interview, `logslayer` is your answer to "tell me about something you built." Lead with the spoofed username. Most people have never thought about a log lying to them.
