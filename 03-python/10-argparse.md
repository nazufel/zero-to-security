# Command-line tools with argparse

**Pillars:** 🤖 AI

## Why this matters

So far your scripts have file names and numbers written into the code. Real tools take them from the command line, like `grep "Failed" auth.log` or `ssh lab`. That turns a script into a tool other people, other scripts, and pipelines can use.

Python's built-in **argparse** handles it: options, flags, help text, and clear errors when someone uses the tool wrong. Built in means nothing extra to install or trust.

## Do it

1. Build a small tool that uses what you learned in [lesson 7](07-never-trust-input.md). Create `ipcheck.py` in `~/my-security-portfolio/python/`:

   ```python
   # ipcheck.py: check whether IP addresses are valid, and whether they're on the public internet
   import argparse
   import ipaddress
   import sys

   parser = argparse.ArgumentParser(description="Check IP addresses.")
   parser.add_argument("ips", nargs="+", help="one or more IP addresses to check")
   parser.add_argument("-q", "--quiet", action="store_true", help="print nothing; only set the exit code")
   args = parser.parse_args()

   bad = 0
   for text in args.ips:
       try:
           ip = ipaddress.ip_address(text)
       except ValueError:
           bad += 1
           if not args.quiet:
               print(f"{text}: NOT a valid IP address")
           continue
       if not args.quiet:
           where = "public internet" if ip.is_global else "not public"
           print(f"{text}: valid IPv{ip.version}, {where}")

   sys.exit(1 if bad else 0)
   ```

   | Line | What it does |
   |---|---|
   | `add_argument("ips", nargs="+")` | A **positional** argument: required, one or more values |
   | `add_argument("-q", "--quiet", action="store_true")` | A **flag**: `True` if given, `False` if not |
   | `args = parser.parse_args()` | Reads the command line. Then `args.ips` and `args.quiet` hold the values. |

2. Get help for free:

   ```bash
   python3 ipcheck.py --help
   ```

   ```
   usage: ipcheck.py [-h] [-q] ips [ips ...]

   Check IP addresses.

   positional arguments:
     ips          one or more IP addresses to check

   options:
     -h, --help   show this help message and exit
     -q, --quiet  print nothing; only set the exit code
   ```

   You wrote none of that. argparse built it from your `help=` text.

3. Use it:

   ```bash
   python3 ipcheck.py 8.8.8.8 10.0.0.1 203.0.113.7 999.1.1.1
   ```

   ```
   8.8.8.8: valid IPv4, public internet
   10.0.0.1: valid IPv4, not public
   203.0.113.7: valid IPv4, not public
   999.1.1.1: NOT a valid IP address
   ```

   `203.0.113.7` is "not public" even though it's an attacker in your sample log. It's from a range reserved for documentation and examples, which is why this course uses it: no real person's IP address appears in the examples. Real attackers' IPs would show as public.

4. Use the exit code, so other tools can act on the answer:

   ```bash
   python3 ipcheck.py -q 8.8.8.8 && echo "all valid"
   python3 ipcheck.py -q 999.1.1.1 || echo "something was invalid"
   ```

   `&&` runs the next command only if the first one succeeded (exit code 0). `||` runs it only if the first one failed. That's how scripts and pipelines chain tools together.

## Break it

Use the tool wrong, on purpose:

```bash
python3 ipcheck.py
```

```
usage: ipcheck.py [-h] [-q] ips [ips ...]
ipcheck.py: error: the following arguments are required: ips
```

```bash
python3 ipcheck.py 8.8.8.8 --verbose
```

```
usage: ipcheck.py [-h] [-q] ips [ips ...]
ipcheck.py: error: unrecognized arguments: --verbose
```

Check the exit code after each with `echo $?`. It's `2`, argparse's code for "you used it wrong." A clear error and a usage line, instead of a crash deep in your code. That's what a well-behaved tool does with input it didn't expect.

## With Claude

In `~/my-security-portfolio/python`, start `claude`:

```text
Add a --file option to ipcheck.py that reads IP addresses from a file, one per
line, in addition to any on the command line. Explain your changes before you
make them.
```

**Check the work:** before you approve, read the diff. Then test it like an attacker would:

- A file that doesn't exist. Does it fail clearly ([lesson 6](06-errors.md)), or crash with a traceback?
- A file with blank lines and spaces around the IPs. Are they handled, or reported as invalid?
- A file with a line like `8.8.8.8; rm -rf ~`. It should just be "NOT a valid IP address." Did Claude add any `os.system` or `shell=True`? ([Lesson 7](07-never-trust-input.md).)

> **Free AI path:** do this with OpenCode; the prompt is the same.

```bash
git add ipcheck.py
git commit -m "Add ipcheck command-line tool"
git push
```

## Check yourself

1. What's the difference between a positional argument and a flag?
   <details><summary>Answer</summary>

   A positional argument is a required value identified by its position, like the file in `grep pattern file`. A flag is optional and named, like `--quiet`.
   </details>

2. Why does `ipcheck.py` exit with `1` when an IP is invalid?
   <details><summary>Answer</summary>

   So other programs and scripts can act on the result without reading the text. 0 means success, anything else means failure.
   </details>

3. What do you get from argparse without writing it yourself?
   <details><summary>Answer</summary>

   `--help` output, usage messages, and clear errors for missing or unknown arguments, with exit code 2.
   </details>

## Go deeper

- [argparse tutorial](https://docs.python.org/3/howto/argparse.html): the official walkthrough, from one argument to subcommands.
