# Making decisions and repeating

**Pillars:** 🤖 AI

## Why this matters

Every security tool you'll use is built from two ideas: "if this, do that," and "do this for every line." A SOC alert rule is an `if`. A log scanner is a `for` loop. An account lockout after three wrong passwords is a `while` loop. Once you can write these, you can read the logic of almost any tool, including the ones AI writes for you.

## Do it

1. **Decisions** with `if`, `elif`, and `else`. Create `triage.py` in `~/my-security-portfolio/python/`:

   ```python
   # triage.py: decide what to do about an IP with failed logins
   failures = 7

   if failures >= 10:
       print("BLOCK: likely brute force")
   elif failures >= 3:
       print("WATCH: keep an eye on it")
   else:
       print("OK: probably a typo")
   ```

   ```bash
   python3 triage.py
   ```

   ```
   WATCH: keep an eye on it
   ```

   Python checks each condition from the top and runs the **first** one that's true. Change `failures` to `12`, then `1`, and run it each time.

   **Indentation is the syntax.** The four spaces before each `print` are how Python knows those lines belong to that `if`.

2. **Repeating** with `for`. Add to the end of `triage.py`:

   ```python
   print()
   lines = [
       "Failed password for root from 192.0.2.44 port 55001 ssh2",
       "session opened for user root",
       "Failed password for deploy from 203.0.113.7 port 51201 ssh2",
   ]

   count = 0
   for line in lines:
       if "Failed password" in line:
           count = count + 1
           print("FAILED:", line)

   print(f"{count} failed logins")
   ```

   ```
   FAILED: Failed password for root from 192.0.2.44 port 55001 ssh2
   FAILED: Failed password for deploy from 203.0.113.7 port 51201 ssh2
   2 failed logins
   ```

   `for line in lines` runs the indented block once per item. `"Failed password" in line` asks whether one string appears inside another. That's `grep` from Module 2, written in Python.

3. **Repeating until something changes** with `while`. Create `lockout.py`:

   ```python
   # lockout.py: three tries, then you're locked out
   correct = "correct horse battery staple"
   attempts = 0

   while attempts < 3:
       guess = input("Password: ")
       if guess == correct:
           print("Welcome.")
           break
       attempts = attempts + 1
       print(f"Wrong. {3 - attempts} tries left.")

   if attempts == 3:
       print("Account locked.")
   ```

   Run it and get it wrong three times. Then run it and get it right. `input()` waits for you to type. `break` leaves the loop early. (A real system never keeps the password in the code. You'll see how real ones store it in Module 4.)

## Break it

Remove the indentation from the `print` under the first `if` in `triage.py`:

```python
if failures >= 10:
print("BLOCK: likely brute force")
```

```
  File "/home/you/my-security-portfolio/python/triage.py", line 5
    print("BLOCK: likely brute force")
    ^^^^^
IndentationError: expected an indented block after 'if' statement on line 4
```

Python tells you what it expected and where. Put the four spaces back.

Now a quieter bug. In `lockout.py`, delete the line `attempts = attempts + 1` and run it with wrong passwords. It never locks you out. It asks forever. Press `Ctrl+C` to stop it. A loop whose condition never changes is an **infinite loop**, and a lockout that never locks is a security bug, not just a code bug. Put the line back.

## With Claude

In `~/my-security-portfolio/python`, start `claude`:

```text
Read lockout.py. Without changing it, what are the security weaknesses of
this lockout? Explain like I'm new to security.
```

**Check the work:** for each weakness Claude names, decide whether it's really in *this* code or a general point about lockouts. Two to look for: the password is in the source file, and restarting the program resets the counter. Did Claude invent problems the code doesn't have? Add anything you learn to your [AI check log](../01-ai-foundations/01-what-ai-is.md).

> **Free AI path:** do this with OpenCode; the prompt is the same.

```bash
git add triage.py lockout.py
git commit -m "Add triage and lockout practice"
git push
```

## Check yourself

1. With `failures = 3`, what does `triage.py` print? Why not "OK"?
   <details><summary>Answer</summary>

   `WATCH: keep an eye on it`. `3 >= 3` is true, so the `elif` runs, and Python stops at the first true condition.
   </details>

2. What's the difference between `for` and `while`?
   <details><summary>Answer</summary>

   `for` runs once per item in a collection. `while` runs as long as a condition stays true, so something inside it must eventually make the condition false.
   </details>

3. What does `break` do?
   <details><summary>Answer</summary>

   It leaves the loop immediately, skipping any remaining repeats.
   </details>

## Go deeper

- [Python tutorial: control flow](https://docs.python.org/3/tutorial/controlflow.html): `if`, `for`, `while`, and `range()`, officially.
