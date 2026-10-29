# Your first script

**Pillars:** 🤖 AI

## Why this matters

By the end of this module you'll have built `logslayer`, a tool that reads a server's login log and shows who's trying to break in. You'll also have Claude extend it. Neither works unless you can read Python, because you can't check code you can't read.

Everything starts with values and their types. Mix up a number and a piece of text and Python stops you. That's a feature.

## Do it

Work in your VM. Ubuntu comes with Python.

1. Check the version:

   ```bash
   python3 --version
   ```

   ```
   Python 3.14.3
   ```

   Any 3.12 or newer is fine.

2. Try the **REPL**, an interactive prompt where Python runs each line as you type it:

   ```bash
   python3
   ```

   ```python
   >>> 2 + 3
   5
   >>> "203.0.113.7"
   '203.0.113.7'
   >>> type(12)
   <class 'int'>
   >>> type("12")
   <class 'str'>
   >>> type(0.5)
   <class 'float'>
   >>> type(True)
   <class 'bool'>
   >>> exit()
   ```

   The four basic types:

   | Type | What it holds | Example |
   |---|---|---|
   | `str` | Text, in quotes | `"root"`, `"203.0.113.7"` |
   | `int` | Whole numbers | `12`, `0`, `-1` |
   | `float` | Numbers with a decimal point | `0.5`, `99.9` |
   | `bool` | True or false | `True`, `False` |

   `12` and `"12"` look alike but aren't the same thing. One is a number you can add to. The other is two characters of text.

3. Write a script. Make a folder in your portfolio for this module's practice:

   ```bash
   mkdir -p ~/my-security-portfolio/python
   cd ~/my-security-portfolio/python
   nano first.py
   ```

   ```python
   # first.py: my first Python script
   server = "web01"
   failures = 12
   threshold = 10
   blocked = failures >= threshold

   print("Server:", server)
   print(f"{failures} failed logins (threshold {threshold})")
   print("Block it?", blocked)
   ```

   ```bash
   python3 first.py
   ```

   ```
   Server: web01
   12 failed logins (threshold 10)
   Block it? True
   ```

   A **variable** is a name for a value: `failures = 12`. The `f` before a string makes it an **f-string**: anything in `{curly braces}` is filled in with its value. `failures >= threshold` is a comparison, and its answer is a `bool`.

## Break it

Add one line to the end of `first.py`:

```python
print("Failed logins: " + failures)
```

Run it:

```
Traceback (most recent call last):
  File "/home/you/my-security-portfolio/python/first.py", line 10, in <module>
    print("Failed logins: " + failures)
          ~~~~~~~~~~~~~~~~~~^~~~~~~~~~
TypeError: can only concatenate str (not "int") to str
```

Read it the way you learned in [Getting unstuck](../00-start-here/05-getting-unstuck.md): **last line first.** You tried to join ("concatenate") text and a number. Python won't guess which one you meant. The line above points to the exact spot.

Fix it either way, and run it again:

```python
print("Failed logins: " + str(failures))
print(f"Failed logins: {failures}")
```

Going the other way: text from a file or a user is always a `str`, even when it looks like a number. `int("12")` turns it into a number. You'll need that in lesson 5.

## With Claude

This is the module where you start Claude Pro (or the [free AI path](../appendix/free-ai-path.md)). If you haven't set up Claude Code in your VM yet, do [Module 2, lesson 11](../02-linux/11-claude-code-in-the-box.md) now.

```bash
cd ~/my-security-portfolio/python
claude
```

```text
Look at first.py. Without changing it, explain what would happen if I set
failures = "12" (with quotes) instead of 12. Which lines would break, and how?
```

**Check the work:** make the change yourself and run it. Did it break where Claude said, with the error Claude predicted? (Hint: comparing a `str` with an `int` using `>=` is its own error.) Put it back when you're done.

> **Free AI path:** do this with OpenCode; the prompt is the same.

```bash
git add first.py
git commit -m "Add first Python script"
git push
```

## Check yourself

1. What's the type of each: `"80"`, `80`, `80.0`, `80 > 22`?
   <details><summary>Answer</summary>

   `str`, `int`, `float`, `bool`. The comparison is a question, and its answer is `True` or `False`.
   </details>

2. You read the number `"5"` from a file and want to add 1 to it. What do you do?
   <details><summary>Answer</summary>

   Convert it first: `int("5") + 1`. Anything read from a file or typed by a user starts as a `str`.
   </details>

3. A traceback is 20 lines long. Where do you start reading?
   <details><summary>Answer</summary>

   The last line. It names the error. The lines above show where it happened.
   </details>

## Go deeper

- [The official Python tutorial](https://docs.python.org/3/tutorial/): free, clear, and the source of truth when Claude and a blog disagree.
