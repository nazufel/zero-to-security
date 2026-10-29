# Functions

**Pillars:** 🤖 AI

## Why this matters

A **function** is a named piece of code you can reuse: give it inputs, get back an output. Functions are how you break a tool into pieces small enough to understand, test, and trust. When you review AI-written code, you'll review it one function at a time. When you test code in lesson 11, you'll test one function at a time.

## Do it

1. Turn the triage logic from lesson 2 into a function. Create `functions.py`:

   ```python
   # functions.py: reusable pieces for a log tool

   def classify(failures):
       """Return a verdict for an IP with this many failed logins."""
       if failures >= 10:
           return "BLOCK"
       elif failures >= 3:
           return "WATCH"
       else:
           return "OK"


   print(classify(12))
   print(classify(4))
   print(classify(1))
   ```

   ```bash
   python3 functions.py
   ```

   ```
   BLOCK
   WATCH
   OK
   ```

   - `def` defines a function. `failures` is its **parameter**: the input.
   - The string in triple quotes is a **docstring**: a one-line description for humans.
   - `return` sends a value back to whoever called the function, and ends the function right there.

2. Add a second function, with two parameters and a default:

   ```python
   def is_failed_login(line, keyword="Failed password"):
       """Return True if this log line is a failed login."""
       return keyword in line


   print(is_failed_login("Failed password for root from 192.0.2.44 port 55001 ssh2"))
   print(is_failed_login("session opened for user root"))
   print(is_failed_login("Invalid user admin from 198.51.100.23", keyword="Invalid user"))
   ```

   ```
   True
   False
   True
   ```

   `keyword="Failed password"` is a **default value**: used unless the caller gives a different one.

3. Use the functions together:

   ```python
   lines = [
       "Failed password for root from 192.0.2.44 port 55001 ssh2",
       "Failed password for root from 192.0.2.44 port 55001 ssh2",
       "Failed password for root from 192.0.2.44 port 55001 ssh2",
       "session opened for user root",
   ]

   count = 0
   for line in lines:
       if is_failed_login(line):
           count += 1

   print(f"{count} failures: {classify(count)}")
   ```

   ```
   3 failures: WATCH
   ```

   `count += 1` is short for `count = count + 1`. Notice how readable the loop is now. The details live in the functions, and their names say what they do.

## Break it

The most common function bug: **printing instead of returning.** Change `classify` so it prints its verdict instead:

```python
def classify(failures):
    if failures >= 10:
        print("BLOCK")
```

Then try to use its answer:

```python
result = classify(12)
print("The verdict is:", result)
```

```
BLOCK
The verdict is: None
```

The function *showed* "BLOCK" on the screen, but gave nothing back. In Python, a function with no `return` gives back `None`, meaning "nothing." Code that tries to use the answer, like a blocklist or a report, gets nothing. AI-written code makes this mistake too, so look for it. Put the `return` statements back.

## With Claude

In `~/my-security-portfolio/python`, start `claude`:

```text
Read functions.py. Suggest one more small function that a log tool would
need, and write it, but explain it to me before you change the file.
```

Approve the edit only after you've read it. (In Manual mode, Claude shows you the change and asks first.)

**Check the work:** call Claude's new function yourself with at least three inputs, including one where it should say no, false, or nothing. Does it `return` a value, or just `print` one? Does the docstring match what the code actually does?

> **Free AI path:** do this with OpenCode; the prompt is the same.

```bash
git add functions.py
git commit -m "Add log helper functions"
git push
```

## Check yourself

1. What does a function return if it has no `return` statement?
   <details><summary>Answer</summary>

   `None`. Printing something isn't the same as returning it.
   </details>

2. Given `def greet(name, greeting="Hello"):`, what does `greet("alice")` use for `greeting`?
   <details><summary>Answer</summary>

   `"Hello"`, the default, because the caller didn't pass one.
   </details>

3. Why split a tool into small functions?
   <details><summary>Answer</summary>

   Each one is small enough to understand, test, and review by itself, and the names make the main code read like a description of what it does.
   </details>

## Go deeper

- [Python tutorial: defining functions](https://docs.python.org/3/tutorial/controlflow.html#defining-functions): defaults, keyword arguments, and docstrings.
