# Claude Code in the box

**Pillars:** 🤖 AI · 🪪 Identity

## Why this matters

Until now, Claude could only talk. **Claude Code** is an agent: it reads files, edits them, and runs commands. On your laptop, that means your email, your browser sessions, your saved passwords, everything. In your VM, it means one disposable machine you can restore in a minute.

This is the first box from [AI in a box](../01-ai-foundations/05-ai-in-a-box.md), and the first time you'll approve commands an AI wants to run. The rule for the whole course starts here: **you approve every command, and you understand it before you do.**

> **You need Claude Pro for this lesson.** The course suggests starting it at Module 3. If you haven't started yet, either start now, or do this lesson as the first step of Module 3. Can't pay? Use the [free AI path](../appendix/free-ai-path.md): install OpenCode in the VM instead, with the same rules.

## Do it

1. **Take a snapshot.** You're about to let an AI run commands.

2. Download the installer and **read it before you run it**. Many install guides say to pipe a script from the internet straight into `bash`. That runs code you haven't seen with your permissions. Look first:

   ```bash
   curl -fsSL https://claude.ai/install.sh -o install.sh
   less install.sh
   ```

   You won't understand every line yet. Look for where it downloads from, where it installs to, and whether it uses `sudo`. Then run it:

   ```bash
   bash install.sh
   ```

   > **Last verified:** 2026-10-29 ([Claude Code docs](https://code.claude.com/docs/en/overview)). If the install command has changed, follow the docs.

3. Open a new SSH session (so your shell picks up the new command), and check:

   ```bash
   claude --version
   ```

4. Start it in a project folder, never in `/` or your whole home directory. It can work in the folder you start it in.

   ```bash
   cd ~/my-security-portfolio
   claude
   ```

   The VM has no browser, so Claude Code shows a link. Open it on your laptop, log in, and paste the code back.

5. Learn the **permission modes**. Press `Shift+Tab` to cycle through them, and watch the label at the bottom of the screen:

   | Mode | What Claude can do without asking | Use it |
   |---|---|---|
   | **Manual** (default) | Read files. Everything else asks first. | **All of this module** |
   | **Accept edits** | Edit files in the folder. Commands still ask. | Later, once you review diffs well (Module 3) |
   | **Plan** | Read and propose only. No edits. | Before any big change |
   | **Auto** | Runs actions; a safety check reviews them instead of you | Not in this course yet |
   | **Bypass permissions** | Everything, no questions | Only in a throwaway box. Never on a machine you care about. |

   Stay in **Manual** for this whole module.

6. Add a hard rule. Prompts and instructions can be ignored; a **deny rule** can't. Quit Claude Code (`/exit`), then:

   ```bash
   mkdir -p ~/.claude
   nano ~/.claude/settings.json
   ```

   ```json
   {
     "permissions": {
       "deny": [
         "Bash(sudo *)"
       ]
     }
   }
   ```

   Claude Code is now blocked from running any command that starts with `sudo`. Admin work is yours, not its.

7. Start `claude` again and give it a read-only job:

   ```text
   Look at the files in this repo and tell me what's here. Don't change anything.
   ```

   It may ask to run commands like `ls` or `git log`. For each one, **say out loud what the command does before you approve it.** If you can't, choose no and ask Claude to explain it first.

## Break it

Ask Claude to do admin work:

```text
Update all the system packages on this machine.
```

It'll try something like `sudo apt update`. Your deny rule blocks it, and Claude tells you it can't run that command. That's the box working: the instruction was reasonable, the AI tried to help, and a rule you set in advance decided the answer.

Now think about what's **not** blocked. Ask yourself, then check:

```bash
ls ~/.config/gh/
```

Your GitHub login from lesson 5 lives here. Claude Code runs as your user, so it can read what you can read, and it could run `git push` to your repos. In Manual mode it asks first, but one careless "yes" is all it takes. Write down, in one or two sentences, what Claude could do in this VM without `sudo`. That's its **blast radius**. You'll shrink it in later modules with containers (Module 5), its own cloud role (Module 7), and hooks and managed settings (Module 8).

A deny rule is a seatbelt, not a vault. A determined attacker, or a prompt injection, might find a way around a single rule. That's why the VM matters: even if everything else fails, the damage stays in a box you can restore.

## With Claude

Have Claude Code investigate your server:

```text
What's listening on the network on this machine? For each one, tell me what
it is and whether a learning VM needs it. Don't change anything.
```

**Check the work:**

- Before approving each command, say what it does. You know `ss`, `systemctl`, and `grep` from this module.
- Check its findings against your own `sudo ss -tlnp` (you run it, since Claude can't use `sudo`).
- Did it suggest disabling `ssh`? You know why that's a bad idea.

Then add an entry to your [AI check log](../01-ai-foundations/01-what-ai-is.md): what Claude got right, and what you had to correct.

> **Free AI path:** do this with OpenCode in the VM, with shell commands set to **ask**. OpenCode's permissions use different syntax; see its docs to deny `sudo`.

## Check yourself

1. Why install Claude Code in the VM instead of on your laptop?
   <details><summary>Answer</summary>

   An agent can do anything your user can. In the VM, that's one disposable machine with a snapshot. On your laptop, it's your whole digital life.
   </details>

2. Claude asks to run `find . -name "*.log" -delete`. What do you do?
   <details><summary>Answer</summary>

   Say what it does: deletes every `.log` file under the current folder. If that's not what you want, say no. If it is, it's still worth asking it to run the search without `-delete` first so you can see what would go.
   </details>

3. What's the difference between your `CLAUDE.md` instructions (Module 3) and the deny rule you set here?
   <details><summary>Answer</summary>

   Instructions are guidance the AI usually follows. A deny rule is enforced by Claude Code itself, every time. You want both.
   </details>

## Go deeper

- [Claude Code permissions](https://code.claude.com/docs/en/permissions): every mode and rule type, from the official docs.
- [Claude Code security](https://code.claude.com/docs/en/security): how Anthropic thinks about keeping the agent safe, and what's still your job.
