# Git and GitHub

## Why this matters

Git tracks every change to a set of files, forever. GitHub hosts those files online. Every engineering team uses them, and your **public GitHub repo is your portfolio**: the first place a hiring manager looks to see if you can actually do the work.

There's a security angle too. Git never forgets. Secrets committed by accident are one of the most common ways companies get breached, and you'll see why in the Break it step.

## Do it

### 1. Install Git and the GitHub CLI

> **Last verified:** 2026-10-27

**Mac:** install [Homebrew](https://brew.sh/), the standard Mac package manager, by following the one-line instruction on its homepage. Then open **Terminal** and run:

```bash
brew install git gh
```

**Windows:** open **PowerShell** and run:

```powershell
winget install --id Git.Git -e
winget install --id GitHub.cli -e
```

Then close PowerShell and open **Git Bash** from the Start menu. Use Git Bash for the rest of this module.

Check that it worked:

```bash
git --version
gh --version
```

You should see two version numbers. Any recent version is fine.

> **Why `gh`?** Pushing to GitHub needs a login. The GitHub CLI handles that through your browser, so you never paste a password into the terminal.

### 2. Make a GitHub account and log in

Sign up at [github.com](https://github.com/) if you haven't. Pick a professional username: it'll be on your resume.

**Turn on two-factor authentication now** (Settings → Password and authentication). Your portfolio is your reputation; protect it.

Then log in from the terminal:

```bash
gh auth login
```

Choose **GitHub.com → HTTPS → Yes (authenticate Git) → Login with a web browser**, and follow the prompts.

### 3. Tell Git who you are

GitHub gives you a private "noreply" email so your real address isn't published in every commit. Find it under **Settings → Emails** (it looks like `12345678+yourname@users.noreply.github.com`).

```bash
git config --global user.name "Your Name"
git config --global user.email "12345678+yourname@users.noreply.github.com"
git config --global init.defaultBranch main
```

> **Why the noreply email?** Commit emails are public. Scrapers harvest them for spam and phishing. That's your first privacy decision as a security person.

### 4. Create your portfolio repo

```bash
gh repo create my-security-portfolio --public --clone
cd my-security-portfolio
```

You now have an empty repo on GitHub *and* a copy on your laptop, linked together.

### 5. The loop you'll use forever

Every change follows the same four steps: **change → add → commit → push.**

```bash
echo "# My Security Portfolio" > README.md
git status
```

`git status` shows `README.md` in red as **untracked**: Git sees it but isn't saving it yet.

```bash
git add README.md
git status
```

Now it's green: **staged**, ready to be saved.

```bash
git commit -m "Add README"
git push -u origin main
```

Open your repo on github.com. Your README is there. 🎉

Now add the files from the earlier lessons. Move `job-research.md` and `rules-of-engagement.md` into this folder, then:

```bash
git add job-research.md rules-of-engagement.md
git commit -m "Add job research and rules of engagement"
git push
```

(After the first push, plain `git push` is enough.)

### 6. See your history

```bash
git log --oneline
```

Every commit, newest first. This is your project's memory.

## Break it

Let's leak a (fake) secret and try to take it back.

```bash
echo "aws_secret=FAKE-1234-not-real" > notes.txt
git add notes.txt
git commit -m "Add notes"
```

Oops. Delete it:

```bash
git rm notes.txt
git commit -m "Remove notes"
```

It's gone, right? Look again:

```bash
git log -p --all -- notes.txt
```

There's your "secret," sitting in the history. **Deleting a file doesn't remove it from Git.** If you'd pushed this, anyone could read it, and bots scan GitHub for leaked keys within minutes of a push.

**Do not push this.** Undo both commits:

```bash
git reset --hard HEAD~2
git log --oneline
```

The two commits are gone because they never left your laptop. Once something is pushed, the only safe fix for a leaked secret is to **treat it as stolen and replace it**. You'll practice this for real in Module 9.

## With Claude

Run `git status` while you have a half-finished change (edit `README.md`, stage it, then edit it again). Paste the output into [claude.ai](https://claude.ai) and ask:

```text
Explain this git status output line by line. What will happen if I commit right now?
```

**Check the work:** commit, then run `git show --stat` and `git status`. Was Claude right about what got committed and what didn't?

## Check yourself

1. What's the difference between `git add` and `git commit`?
   <details><summary>Answer</summary>

   `add` chooses which changes go into the next save (staging). `commit` saves them to history. Two steps so you can pick exactly what goes in each commit.
   </details>

2. You pushed a file with a real password, then deleted it in the next commit. Is the password safe?
   <details><summary>Answer</summary>

   No. It's still in the history, and it may already have been copied. Change the password immediately; cleaning up the repo comes second.
   </details>

3. What does `git log --oneline` show?
   <details><summary>Answer</summary>

   A one-line summary of every commit, newest first.
   </details>

## Go deeper

- [Pro Git, chapters 1–3](https://git-scm.com/book/en/v2): free, official, and the best Git explanation there is.
- [Learn Git Branching](https://learngitbranching.js.org/): an interactive visual game for when you're ready for branches.
