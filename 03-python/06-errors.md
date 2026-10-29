# Errors

**Pillars:** 🤖 AI

## Why this matters

Things go wrong: files go missing, permissions get denied, logs get cut off mid-line. A program that crashes with a 20-line traceback in front of a user is annoying. A program that **hides** an error and carries on as if everything's fine is dangerous.

OWASP added a whole category for this in its 2025 Top 10: **A10, Mishandling of Exceptional Conditions.** The classic case is "fail open": a security check hits an error and lets everyone in.

## Do it

1. Make an error happen. In `~/my-security-portfolio/python`, edit `read_log.py` and change `"auth.log"` to `"auth.lgo"`. Run it:

   ```
   Traceback (most recent call last):
     File "/home/you/my-security-portfolio/python/read_log.py", line 5, in <module>
       with open("auth.lgo") as log:
            ~~~~^^^^^^^^^^^^
   FileNotFoundError: [Errno 2] No such file or directory: 'auth.lgo'
   ```

   You know the drill: **last line first.** The error type is `FileNotFoundError`. The line above it shows the exact call that failed. The `File ... line 5` line shows where.

2. Now point it at the real system log, which you can't read without `sudo`:

   ```python
   with open("/var/log/auth.log") as log:
   ```

   ```
   PermissionError: [Errno 13] Permission denied: '/var/log/auth.log'
   ```

   Two different problems, two different error types. That matters: you can handle each one differently.

3. **Handle** them with `try` and `except`. Create `safe_read.py`:

   ```python
   # safe_read.py: read a log, and fail clearly instead of crashing
   import sys

   path = "/var/log/auth.log"

   try:
       with open(path) as log:
           lines = log.readlines()
   except FileNotFoundError:
       print(f"No such file: {path}", file=sys.stderr)
       sys.exit(1)
   except PermissionError:
       print(f"Permission denied: {path} (try sudo)", file=sys.stderr)
       sys.exit(1)

   print(f"Read {len(lines)} lines from {path}")
   ```

   ```bash
   python3 safe_read.py
   sudo python3 safe_read.py
   ```

   ```
   Permission denied: /var/log/auth.log (try sudo)
   Read 214 lines from /var/log/auth.log
   ```

   - `try:` runs the risky code.
   - Each `except` catches **one specific** error type and says what to do about it.
   - `file=sys.stderr` sends the message to the error stream, where error messages belong.
   - `sys.exit(1)` stops the program with exit code 1, the signal to other programs and scripts that something failed.

## Break it

Here's how error handling becomes a vulnerability. Create `allowlist.py`:

```python
# allowlist.py: only users on the list may log in
def load_allowlist():
    with open("allowed_users.txt") as f:
        return f.read().split()


def is_allowed(user):
    try:
        return user in load_allowlist()
    except Exception:
        return True


print("alice allowed?", is_allowed("alice"))
print("mallory allowed?", is_allowed("mallory"))
```

```bash
echo "alice bob" > allowed_users.txt
python3 allowlist.py
```

```
alice allowed? True
mallory allowed? False
```

Works fine. Now the file goes missing, the way files do:

```bash
rm allowed_users.txt
python3 allowlist.py
```

```
alice allowed? True
mallory allowed? True
```

Mallory is in. `except Exception:` caught **every** error, and `return True` turned "I couldn't check" into "yes." That's **failing open**. The person who wrote it probably just wanted to stop a crash.

Fix it so it **fails closed**: if you can't check, the answer is no. Change `return True` to `return False`, and run it again. Even better, catch only `FileNotFoundError` and log a warning, so someone knows the allowlist is missing.

**The rules:** catch specific errors, not `Exception`. Never use a bare `except: pass`. And when a security check can't decide, deny.

## With Claude

In `~/my-security-portfolio/python`, start `claude`:

```text
Review allowlist.py and read_log.py for error-handling problems. For each,
tell me whether it fails open or fails closed. Don't change the files.
```

**Check the work:** check every claim by running the code. Make the error happen (delete or rename a file) and see what really happens. Did Claude flag `except Exception`? Did it suggest a fix that catches everything again, just with a nicer message? A fix can look tidy and still fail open.

> **Free AI path:** do this with OpenCode; the prompt is the same.

```bash
git add safe_read.py allowlist.py
git commit -m "Add error handling practice"
git push
```

## Check yourself

1. Why catch `FileNotFoundError` instead of `Exception`?
   <details><summary>Answer</summary>

   `Exception` catches everything, including bugs you didn't expect, and hides them. Catching the specific error means you only handle the problem you planned for.
   </details>

2. What does "fail open" mean, and why is it dangerous?
   <details><summary>Answer</summary>

   When an error happens, the check allows access instead of denying it. Attackers can trigger errors on purpose to get in.
   </details>

3. What does `sys.exit(1)` tell other programs?
   <details><summary>Answer</summary>

   That the program failed. Exit code 0 means success; anything else means failure. Scripts and pipelines check this.
   </details>

## Go deeper

- [OWASP A10:2025, Mishandling of Exceptional Conditions](https://owasp.org/Top10/2025/): the new category, with real examples of failing open.
