# Module 3: Python

**Pillars:** 🤖 AI

## Why this module matters

AI writes a lot of code now, and you'll use it to. But you can't check work you don't understand, and "check the work" is the job. This module teaches enough Python to read, fix, and extend what AI writes, and to build a real security tool you'll keep growing for the rest of the course.

## Opinions

- **Python**, because security tooling, cloud automation, and AWS Lambda all speak it.
- **[uv](https://docs.astral.sh/uv/)** for projects and packages. You'll learn what `venv` and `pip` do first, so you understand what `uv` does for you.
- **`argparse`** for command-line tools: it's built in, so there's nothing extra to install or trust.
- **pytest** for tests: lean, a few tests per feature.
- **Start Claude Pro here** (about $20/month) to get Claude Code. Or use the [free AI path](../appendix/free-ai-path.md).

## You're ready to move on when…

- [ ] You can use variables and the core data types (str, int, float, bool, list, dict) correctly
- [ ] You can take input and produce output: command-line arguments, files, and JSON
- [ ] You can write conditionals, loops, and functions without looking up the syntax
- [ ] You can write a simple class and explain when one is worth it
- [ ] You can handle errors with `try`/`except` instead of letting the program crash
- [ ] You can explain what a virtual environment and a package manager are, and set up a project with `uv`
- [ ] You can write and run a pytest test
- [ ] You can give Claude Code a `CLAUDE.md`, have it plan before it builds, and review its diff line by line
- [ ] You've built `logslayer` v1 by hand and extended it with Claude

## Lessons

1. [Your first script](01-first-script.md): running Python, `print`, variables, data types
2. [Making decisions and repeating](02-decisions-and-loops.md): `if`, `for`, `while`
3. [Functions](03-functions.md): inputs, outputs, return values
4. [Collections](04-collections.md): lists and dictionaries, the two you'll use daily
5. [Files and JSON](05-files-and-json.md): reading logs, writing reports
6. [Errors](06-errors.md): reading tracebacks, `try`/`except`. *(OWASP A10: Mishandling of Exceptional Conditions)*
7. [Never trust input](07-never-trust-input.md): validating what users and files give you. *(OWASP A05: Injection)*
8. [Classes](08-classes.md): just enough to organize a tool
9. [Packages and package managers](09-packages.md): `venv`, `pip`, then `uv`, and why every package is code you're choosing to trust
10. [Command-line tools with `argparse`](10-argparse.md)
11. [Testing with pytest](11-testing.md)
12. [Building with Claude Code](12-building-with-claude-code.md): `CLAUDE.md`, plan-then-build, reviewing diffs. *Do project part 1 first.*

## Practice

- [Quiz](quiz.md), with a challenge that previews Module 9's detection mode
- [Project: `logslayer`](project.md): a CLI that reads a Linux `auth.log` and reports failed SSH logins by IP address
  - **Part 1, v1 by hand** (after lesson 11): parse the log, count failures per IP, print a report
  - **Part 2, v2 with Claude** (after lesson 12): add JSON output, a `--top N` flag, and tests. You review every change.
- [Sample `auth.log`](samples/auth.log): the log the lessons and project use, including a spoofed username and a cut-off line

`logslayer` grows through the course: it gets containerized in Module 5, learns to read CloudTrail in Module 6, and gets a detection mode in Module 9.

## Dig Deeper

- [Automate the Boring Stuff with Python](https://automatetheboringstuff.com/) (free to read online)
