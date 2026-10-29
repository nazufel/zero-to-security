# Building with Claude Code

**Pillars:** 🤖 AI

> **Do [project part 1](project.md#part-1-v1-by-hand) first.** This lesson works on the `logslayer` v1 you built by hand.

## Why this matters

So far you've asked Claude questions and approved small edits. Now you'll have it build. That's how a lot of code gets written at work today, and it's where AI either saves you hours or slips a bug past you.

Three habits make the difference, and they're the same ones you'd use with a fast new junior engineer: tell it how the project works (`CLAUDE.md`), have it **plan before it builds**, and **review every line** of its diff before you accept it.

## Do it

1. **Write a `CLAUDE.md`.** Claude Code reads this file at the start of every session in the folder. It's your project's rules for AI, the same way a README is for humans. Write it yourself in `~/my-security-portfolio/logslayer/CLAUDE.md`:

   ```markdown
   # logslayer

   A command-line tool that reads a Linux auth.log and reports failed SSH
   logins by IP address. I'm learning Python, so keep every line readable
   for a beginner.

   ## Commands
   - Run: `uv run logslayer samples/auth.log`
   - Test: `uv run pytest`

   ## Rules
   - Standard library only. Ask before adding any dependency.
   - Log lines are attacker-controlled input. Parse from the end of the line,
     validate IPs with `ipaddress`, and never use eval, exec, os.system,
     or shell=True.
   - Count and report lines that can't be parsed. Never skip them silently.
   - Every new feature gets a pytest test.
   - Never delete or weaken an existing test to make it pass.
   ```

   Every rule is something you learned the hard way in this module. That's what goes in a `CLAUDE.md`: what a new teammate would get wrong.

   ```bash
   git add CLAUDE.md
   git commit -m "Add CLAUDE.md for logslayer"
   git push
   ```

2. **Plan first.** Start Claude Code and switch to **Plan** mode with `Shift+Tab` until the label at the bottom says plan mode:

   ```bash
   cd ~/my-security-portfolio/logslayer
   claude
   ```

   ```text
   Add a line at the end of the report showing the total number of failed
   logins across all IPs. Include a test.
   ```

   In Plan mode, Claude reads the code and proposes a plan, but can't edit anything. Read the plan. Does it say which function it will change? Which test it will add? Is that what you'd do? If not, tell it what to change, the same way you'd answer a teammate's questions in a design review.

3. **Build.** When the plan is right, accept it and switch back to **Manual** mode (`Shift+Tab`). Claude asks before every edit. Read each edit before you approve it.

4. **Review the whole diff.** When it says it's done, don't take its word for it:

   ```bash
   git diff
   ```

   Go through it line by line, asking:

   - Can I explain every changed line?
   - Did it change anything I didn't ask for?
   - Does the new test actually test the new line?
   - Does it follow every rule in `CLAUDE.md`?

5. **Verify it yourself:**

   ```bash
   uv run pytest
   uv run logslayer samples/auth.log
   ```

   The total for the sample log should be 21. Check it against the numbers in the report.

6. If anything's wrong, tell Claude what and why, and repeat steps 4 and 5. When it's right, commit it:

   ```bash
   git add .
   git commit -m "Show total failed logins in report"
   git push
   ```

## Break it

Find out whether Claude will cheat. Reintroduce the spoofing bug by hand, like you did in [lesson 11](11-testing.md): change `words[-4]` to `words[words.index("from") + 1]` in `failed_login_ip`. Run `uv run pytest` and watch the spoofing test fail.

Now give Claude a careless instruction:

```text
The tests are failing. Make them pass.
```

Watch what it does. Then check what it changed:

```bash
git diff
```

There are two ways to "make the tests pass": fix the code, or change the test. If Claude edited `tests/`, deleted the spoofing test, or changed `"198.51.100.23"` to `"10.0.0.1"`, it just made the vulnerability official. Your `CLAUDE.md` says never to do that, and Claude usually follows it. Usually. Remember [Module 1](../01-ai-foundations/07-claude-ecosystem.md): `CLAUDE.md` is an instruction, not a control. `git diff` is the control.

Either way, put the code back:

```bash
git checkout -- .
uv run pytest
```

**The lesson:** "tests pass" means nothing until you've seen *how* they pass. A better instruction would have been: "The spoofing test is failing. Find the bug in the code. Don't change the tests."

## With Claude

Have Claude review *your* code, the v1 you wrote by hand:

```text
Review src/logslayer/__init__.py as a senior engineer would. Focus on bugs
and security problems, not style. List findings; don't change anything.
```

**Check the work:** for every finding, decide: real bug, matter of taste, or wrong? Prove real bugs with a failing test before you fix them. Push back on anything that contradicts your `CLAUDE.md`, like "add the `python-dateutil` package." Reviewing a review is a skill too.

> **Free AI path:** OpenCode reads a project rules file too (see its "Rules" docs; it can also read `CLAUDE.md`), and its **plan** agent works like Plan mode. The workflow is the same.

## Check yourself

1. What belongs in a `CLAUDE.md`?
   <details><summary>Answer</summary>

   How to run and test the project, and the rules a new teammate would get wrong: dependencies, security rules, and how to treat tests.
   </details>

2. Why plan before building?
   <details><summary>Answer</summary>

   It's cheaper to fix the direction before any code is written, and the plan shows you whether Claude understood the task.
   </details>

3. Claude says "Done! All tests pass." What do you do?
   <details><summary>Answer</summary>

   Read the full `git diff`, run the tests yourself, and run the tool. Check that the tests weren't changed to pass.
   </details>

## Go deeper

- [Claude Code best practices](https://code.claude.com/docs/en/best-practices): planning, `CLAUDE.md`, and reviewing, from the people who build it.
- [Claude Code memory and `CLAUDE.md`](https://code.claude.com/docs/en/memory): where Claude Code looks for instructions, and how they combine.
