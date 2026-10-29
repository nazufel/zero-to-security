# Module 3 quiz

Answer each question out loud or on paper *before* you open the answer. For the code questions, predict the output first, then check in the REPL.

1. What does this print, and why?

   ```python
   port = input("Port: ")   # you type 22
   print(port + 1)
   ```

   <details><summary>Answer</summary>

   A `TypeError`. `input()` always returns a `str`, so `"22" + 1` mixes text and a number. Use `int(port) + 1`.
   </details>

2. What does this print?

   ```python
   def check(count):
       if count > 5:
           print("ALERT")

   result = check(9)
   print(result)
   ```

   <details><summary>Answer</summary>

   `ALERT`, then `None`. The function prints but never returns, so `result` is `None`.
   </details>

3. Fix this so it counts each IP correctly:

   ```python
   counts = {}
   for ip in ips:
       counts[ip] += 1
   ```

   <details><summary>Answer</summary>

   `counts[ip] = counts.get(ip, 0) + 1`. The original raises a `KeyError` the first time it sees each IP.
   </details>

4. You open `report.json` with `open("report.json", "w")` to read it. What happens?
   <details><summary>Answer</summary>

   The file is emptied immediately, and you can't read from it. Use `open("report.json")` (read is the default) and `json.load`.
   </details>

5. What's wrong with this, from a security point of view?

   ```python
   try:
       allowed = check_permissions(user)
   except Exception:
       allowed = True
   ```

   <details><summary>Answer</summary>

   It fails open: any error, including one an attacker causes on purpose, grants access. Catch the specific error you expect, and deny (`False`) when the check can't be completed.
   </details>

6. An SSH log line reads: `Failed password for invalid user root from 10.1.1.1 port 22 from 203.0.113.50 port 40001 ssh2`. Who really tried to log in, and how do you know?
   <details><summary>Answer</summary>

   `203.0.113.50`. sshd writes the final `from <ip> port <port> ssh2`. The earlier `from 10.1.1.1 port 22` is part of a username the attacker typed to frame an internal address.
   </details>

7. Rewrite this safely: `os.system(f"nslookup {domain}")`
   <details><summary>Answer</summary>

   `subprocess.run(["nslookup", domain])`. A list keeps `domain` as data, so input like `example.com; rm -rf ~` can't run a second command.
   </details>

8. What's a virtual environment, and what does `uv.lock` add?
   <details><summary>Answer</summary>

   A virtual environment is a private set of packages for one project. `uv.lock` pins the exact version and file hash of every package, so every install gets identical, untampered code.
   </details>

9. Claude reports: "Fixed! All 12 tests pass." What three things do you check?
   <details><summary>Answer</summary>

   Read the `git diff` (did it change anything unexpected, especially tests?), run `uv run pytest` yourself, and run the tool on real input.
   </details>

10. When is a class worth writing?
    <details><summary>Answer</summary>

    When several values always travel together and have behavior that belongs with them, like an `AuthEvent` with a user, IP, and result. When a function and a dictionary do the job, they're simpler.
    </details>

## Challenge

Without looking at your code, write a function `successful_after_failures(lines)` that returns the IPs that had at least one failed login **followed by** a successful one (`Accepted password for ...`). On the sample log it should return `203.0.113.7` and `10.0.2.2`.

Write the tests first. Then explain out loud which of those two IPs you'd escalate, and why. (Hint: one is a password-guessing attack that worked. The other is `maria` mistyping her password once.)

You'll build this for real in Module 9.
