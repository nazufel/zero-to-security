# Testing with pytest

**Pillars:** 🤖 AI

## Why this matters

A test is a small program that checks your program. You write it once, and it checks your code every time you change anything, forever. When Claude changes your code in the next lesson, the tests are how you'll know it didn't break something it wasn't asked to touch.

For security, tests do one more job: once you've fixed a vulnerability, a test makes sure it stays fixed. The spoofed-username attack from lesson 7 is about to become one.

## Do it

1. Move your safe parser into `logslayer`. In `~/my-security-portfolio/logslayer`, open `src/logslayer/__init__.py`. Keep the `main()` function uv made, and add `failed_login_ip` from [lesson 7](07-never-trust-input.md) above it, with the `import ipaddress` at the top:

   ```python
   """logslayer: report failed SSH logins by IP address."""

   import ipaddress


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


   def main() -> None:
       print("Hello from logslayer!")
   ```

2. Add pytest as a **dev dependency**: something you need while building, but that users of the tool don't:

   ```bash
   uv add --dev pytest
   ```

3. Write tests. Create `tests/test_parse.py`:

   ```python
   from logslayer import failed_login_ip

   PREFIX = "2026-03-14T02:05:40.661230+00:00 web01 sshd[2340]: "


   def test_normal_failed_login():
       line = PREFIX + "Failed password for root from 192.0.2.44 port 55001 ssh2"
       assert failed_login_ip(line) == "192.0.2.44"


   def test_ignores_other_lines():
       line = PREFIX + "Accepted password for maria from 10.0.2.2 port 61022 ssh2"
       assert failed_login_ip(line) is None


   def test_spoofed_username_does_not_change_the_ip():
       line = PREFIX + ("Failed password for invalid user admin from 10.0.0.1 port 22 "
                        "from 198.51.100.23 port 40190 ssh2")
       assert failed_login_ip(line) == "198.51.100.23"


   def test_cut_off_line():
       assert failed_login_ip(PREFIX + "Failed password for ") is None
   ```

   - Test files and functions start with `test_`. That's how pytest finds them.
   - `assert` checks that something is true. If it isn't, the test fails.
   - Each test checks **one** behavior, and its name says which. Two are about normal lines; two are about attacks and broken input.

4. Run them:

   ```bash
   uv run pytest
   ```

   ```
   tests/test_parse.py ....                                                 [100%]

   ============================== 4 passed in 0.01s ===============================
   ```

   Each `.` is a passing test.

5. Commit:

   ```bash
   git add .
   git commit -m "Add failed_login_ip and tests"
   git push
   ```

## Break it

Reintroduce the bug from lesson 7. In `failed_login_ip`, change `words[-4]` to the naive version:

```python
        return str(ipaddress.ip_address(words[words.index("from") + 1]))
```

```bash
uv run pytest
```

```
=================================== FAILURES ===================================
_________________ test_spoofed_username_does_not_change_the_ip _________________

    def test_spoofed_username_does_not_change_the_ip():
        line = PREFIX + ("Failed password for invalid user admin from 10.0.0.1 port 22 "
                         "from 198.51.100.23 port 40190 ssh2")
>       assert failed_login_ip(line) == "198.51.100.23"
E       AssertionError: assert '10.0.0.1' == '198.51.100.23'
E
E         - 198.51.100.23
E         + 10.0.0.1

tests/test_parse.py:19: AssertionError
=========================== short test summary info ============================
FAILED tests/test_parse.py::test_spoofed_username_does_not_change_the_ip - As...
========================= 1 failed, 3 passed in 0.02s ==========================
```

Read it: which test failed, the line that failed (marked `>`), and what it got (`10.0.0.1`) versus what it expected (`198.51.100.23`). The other three tests still pass. Without the spoofing test, this vulnerability would have slipped back in with every test green.

That's a **regression test**: it catches a bug you already fixed, if it ever comes back. Every security fix deserves one. Put `words[-4]` back and run the tests again.

## With Claude

In `~/my-security-portfolio/logslayer`, start `claude`:

```text
Read src/logslayer/__init__.py and tests/test_parse.py. What cases are my
tests missing? List them, but don't write any code yet.
```

Pick the two cases you think matter most, and ask Claude to write tests for just those.

**Check the work:**

- Run `uv run pytest` yourself. Don't trust "all tests pass" from anyone, including Claude.
- For each new test, break the code on purpose so that test *should* fail. Does it? A test that can't fail is worthless.
- Did Claude change anything in `src/` without being asked? Check with `git diff src/`.

> **Free AI path:** do this with OpenCode; the prompt is the same.

```bash
git add tests/
git commit -m "Add more parser tests"
git push
```

## Check yourself

1. How does pytest know which functions are tests?
   <details><summary>Answer</summary>

   Files named `test_*.py` and functions named `test_*`.
   </details>

2. What's a regression test, and why does every security fix need one?
   <details><summary>Answer</summary>

   A test for a bug you already fixed. It makes sure a later change (yours or AI's) doesn't quietly bring the vulnerability back.
   </details>

3. You add a test and it passes on the first run. How do you know it actually tests anything?
   <details><summary>Answer</summary>

   Break the code it's testing on purpose and check that the test fails. Then fix the code.
   </details>

## Go deeper

- [pytest: get started](https://docs.pytest.org/en/stable/getting-started.html): the official quick start, including how to test that errors are raised.
