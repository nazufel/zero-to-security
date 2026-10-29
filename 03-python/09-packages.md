# Packages and package managers

**Pillars:** 🤖 AI

## Why this matters

Python's real power is the half a million free packages on [PyPI](https://pypi.org/), the Python Package Index. Every one of them is code written by strangers that runs with your permissions the moment you install it. Attackers know this. They upload packages with names one typo away from popular ones, and they register the fake package names that AI tools tend to invent ([Module 1](../01-ai-foundations/01-what-ai-is.md)).

So two skills: keeping each project's packages separate, and treating every install as a decision to trust someone.

## Do it

1. Try to install a package the old way, straight into the system:

   ```bash
   cd ~
   python3 -m pip install requests
   ```

   On Ubuntu this fails, either because `pip` isn't installed (`No module named pip`) or with the error in Break it below. Ubuntu won't let you mix your packages into the Python the operating system depends on. That's a good thing.

2. Make a **virtual environment**, a private folder of packages for one project:

   ```bash
   sudo apt install -y python3-venv python3-pip
   mkdir ~/pkg-practice && cd ~/pkg-practice
   python3 -m venv .venv
   source .venv/bin/activate
   ```

   Your prompt now starts with `(.venv)`. Inside it, `pip` installs into this folder only:

   ```bash
   pip install requests
   pip list
   ```

   ```
   Package            Version
   ------------------ ----------
   certifi            2026.10.23
   charset-normalizer 3.5.2
   idna               3.20
   pip                26.0
   requests           2.34.2
   urllib3            2.8.0
   ```

   You asked for one package and got five. `requests` depends on four others, and you're now trusting all of their authors too. These are **transitive dependencies**: dependencies of your dependencies.

   ```bash
   deactivate
   ```

3. That works, but it's a lot to manage by hand: creating the environment, activating it, remembering exact versions so a teammate gets the same ones. **[uv](https://docs.astral.sh/uv/)** does all of it with one tool. Install it. Like Claude Code in [Module 2](../02-linux/11-claude-code-in-the-box.md), read the installer before you run it:

   ```bash
   curl -LsSf https://astral.sh/uv/install.sh -o uv-install.sh
   less uv-install.sh
   sh uv-install.sh
   ```

   Open a new SSH session, then check:

   ```bash
   uv --version
   ```

   > **Last verified:** 2026-10-29 with uv 0.13. If the install command has changed, follow the [uv docs](https://docs.astral.sh/uv/getting-started/installation/).

4. Create the project you'll build for the rest of this module:

   ```bash
   cd ~/my-security-portfolio
   uv init logslayer
   cd logslayer
   ls -a
   ```

   ```
   .  ..  .python-version  README.md  pyproject.toml  src
   ```

   `pyproject.toml` describes the project: its name, Python version, and dependencies. Your code goes in `src/logslayer/__init__.py`. Run it:

   ```bash
   uv run logslayer
   ```

   ```
   Hello from logslayer!
   ```

   `uv run` created a virtual environment in `.venv/`, installed your project into it, and ran it. No `activate` needed.

5. Keep the environment out of Git. Since this folder is inside your portfolio repo, `uv` didn't make a `.gitignore`. Make one:

   ```bash
   printf '.venv/\n__pycache__/\n' > .gitignore
   ```

6. See what adding a dependency looks like, then decide you don't need it:

   ```bash
   uv add requests
   uv tree
   ```

   ```
   logslayer v0.1.0
   └── requests v2.34.2
       ├── certifi v2026.10.23
       ├── charset-normalizer v3.5.2
       ├── idna v3.20
       └── urllib3 v2.8.0
   ```

   Open `uv.lock`. It pins the **exact** version of every package and a `sha256` hash of each file. If anyone swaps a file on PyPI, the hash won't match and the install fails. You'll see the same idea in Module 5 with container image digests.

   `logslayer` doesn't need `requests`. Everything it does is in Python's **standard library**, the modules that come with Python (`json`, `ipaddress`, `argparse`). No dependencies means nothing to trust but Python itself. Remove it:

   ```bash
   uv remove requests
   ```

7. Commit the empty project:

   ```bash
   git add .
   git status
   git commit -m "Create logslayer project with uv"
   git push
   ```

   Check that `git status` didn't list `.venv/` before you committed.

## Break it

Force the system-wide install that step 1 refused:

```bash
sudo apt install -y python3-pip
python3 -m pip install requests
```

```
error: externally-managed-environment

× This environment is externally managed
╰─> To install Python packages system-wide, try apt install
    python3-xyz, where xyz is the package you are trying to
    install.
```

The operating system's own tools are written in Python. If `pip` upgraded one of their packages to a version they don't expect, parts of Ubuntu could break. The error is protecting you. The message also mentions a flag called `--break-system-packages`. Its name tells you what it does. Don't use it. Use a virtual environment.

## With Claude

In `~/my-security-portfolio/logslayer`, start `claude`:

```text
I need to parse dates in log files. Which Python package should I use?
Before you recommend a package, tell me how I'd check that it's legitimate
and well maintained. Don't install anything.
```

**Check the work:** for any package Claude names, look it up yourself on [pypi.org](https://pypi.org/). Does it exist with that exact spelling? When was it last released? Does it link to a real source repository? Then ask: does the standard library already do this? (For dates, `datetime.fromisoformat()` does.) The safest dependency is the one you don't add.

> **Free AI path:** do this with OpenCode; the prompt is the same.

## Check yourself

1. What's a virtual environment, and why use one per project?
   <details><summary>Answer</summary>

   A private folder of packages for one project. It keeps projects from breaking each other, and keeps your packages out of the operating system's Python.
   </details>

2. You `uv add` one package and `uv tree` shows six. Why?
   <details><summary>Answer</summary>

   Transitive dependencies: your package depends on others, which may depend on more. You're trusting the authors of all of them.
   </details>

3. What does `uv.lock` protect against?
   <details><summary>Answer</summary>

   Getting different versions or tampered files. It pins exact versions and file hashes, so every install gets the same, verified code.
   </details>

## Go deeper

- [uv documentation](https://docs.astral.sh/uv/): projects, `uv run`, and the lockfile.
- [Python Packaging User Guide: installing packages](https://packaging.python.org/en/latest/tutorials/installing-packages/): what `pip` and virtual environments do underneath.
