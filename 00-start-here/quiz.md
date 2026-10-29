# Module 0 quiz

Answer each question out loud or on paper *before* you open the answer.

1. Name the three target roles in this course and one thing each does on a normal day.
   <details><summary>Answer</summary>

   Help desk (password resets, account setup, phishing reports), SOC analyst (triaging alerts, reading logs, escalating incidents), junior cloud/security engineer (fixing misconfigurations, reviewing permissions, writing infrastructure code).
   </details>

2. What's the one rule for practicing security skills?
   <details><summary>Answer</summary>

   Only scan or test systems you own or have written permission to test.
   </details>

3. You run `git status` and see a file listed in red under "Untracked files." What does that mean, and what do you run next to save it?
   <details><summary>Answer</summary>

   Git sees the file but isn't tracking it. Run `git add <file>`, then `git commit -m "message"`, then `git push`.
   </details>

4. Put these in order: `push`, `commit`, `add`, change a file.
   <details><summary>Answer</summary>

   Change a file → `add` → `commit` → `push`.
   </details>

5. Why use GitHub's noreply email for your commits?
   <details><summary>Answer</summary>

   Commit emails are public. The noreply address keeps your real email away from scrapers, spam, and phishing.
   </details>

6. A user reports: "The printer on floor 3 has been jammed since this morning." What ticket type is it, and what's missing from the report?
   <details><summary>Answer</summary>

   An incident (it's broken now). Missing: which printer exactly, who's affected, the exact error on the display, and what's been tried.
   </details>

7. Why is it a bad idea to let AI fill in details when it rewrites a ticket?
   <details><summary>Answer</summary>

   AI may invent facts that sound real, like error messages or times, which sends the next engineer the wrong way. Only the person who saw the problem knows what happened.
   </details>

8. What are the four parts of a good question to a human when you're stuck?
   <details><summary>Answer</summary>

   What you're trying to do, what you ran, what you expected, and what happened (exact error). Bonus: what you've already tried.
   </details>

## Challenge

Without looking anything up, create a new file in your portfolio, commit it, and push it. Then run `git log --oneline` and confirm it's there, and check github.com to confirm it's there too.

If you had to look anything up, do it again tomorrow. That's muscle memory.
