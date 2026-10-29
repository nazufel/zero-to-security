# The free AI path (OpenCode)

> **Last verified:** 2026-10-27. Free models and features in this space change often. If something here is out of date, [open an issue](../../../issues/new?template=outdated.md).

## The recommendation, and the alternative

**Recommended:** Claude Pro (about $20/month), started at Module 3. Every "With Claude" section in this course is written for Claude Code, which needs a paid Claude plan. The free Claude plan at [claude.ai](https://claude.ai) is enough for Modules 0 and 1, and for Module 2 up to its last lesson, which installs Claude Code.

**Free alternative:** [OpenCode](https://opencode.ai/), a free, open-source coding agent for the terminal. It works with many AI providers, including a built-in gateway called **Zen** that offers some models for free.

## The catches

**1. Free models rotate.** Zen's free models are usually limited-time offers. This course won't name one, because it'll be gone by the time you read this. Inside OpenCode, run `/models` and pick one marked free.

**2. Your code may become training data.** OpenCode's docs say that during a model's free period, collected data may be used to improve the model.

> This is the lesson from Module 1, in real life: **free AI is often paid for with your data.** That's fine for practice code in this course. It's not fine for anything with secrets, personal data, or your employer's code. Never put those into a free model.

**3. It's not one-to-one.** The ideas carry over (agents, MCP, project rules, permissions), but commands, file names, and features differ. Some Claude Code lessons, like managed settings, have no OpenCode equivalent: read along and learn the concept.

## Setup

1. Install OpenCode **inside your Ubuntu VM**, never on your laptop. The VM is the box. Follow the install instructions at [opencode.ai/docs](https://opencode.ai/docs/).
2. Run `opencode` in a project folder.
3. Run `/models` and choose a model marked free.
4. Read the permissions section of the docs and set file edits and shell commands to **ask** before running. Same rule as Claude Code: you approve every command, and you understand it before you do.

## Claude Code → OpenCode

| Claude Code | OpenCode | Notes |
|---|---|---|
| `claude` in the terminal | `opencode` in the terminal | Same idea: an agent that reads, edits, and runs things in your project |
| `CLAUDE.md` project rules | Project rules file (see OpenCode's "Rules" docs) | Same purpose: tell the agent how your project works |
| Permission modes | Per-tool `allow` / `ask` / `deny` permissions | Set shell commands to `ask` |
| Plan mode | The built-in **plan** agent | Plans and asks before editing |
| Model choice | `/models` | Free model choices rotate |
| MCP servers | MCP servers in config | Same protocol, different config file |
| Subagents | Subagents and custom agents | Defined in config or markdown files |
| Skills (`SKILL.md`) | Skills (`SKILL.md`) | OpenCode also reads `.claude/skills` |
| Hooks | Plugins | Different mechanism. Read along for the hooks lesson. |
| Managed settings | No direct equivalent | Read along. The concept (an org-wide policy for AI) is what matters in interviews. |

## Each module's pointer

Every "With Claude" section ends with a one-line note for this path, like:

> **Free AI path:** do this with OpenCode; the prompt is the same.

or

> **Free AI path:** no OpenCode equivalent, so read along.

## Sources

- [OpenCode Zen docs (mirror)](https://learnopencode.com/en/appendix/zen): free models and the data-use note
- [OpenCode Skills docs](https://opencode.ai/docs/skills)
- [OpenCode pricing guide](https://www.codeagentswarm.com/en/guides/opencode-plans-and-pricing)
