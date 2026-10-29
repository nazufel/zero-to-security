# The Claude ecosystem map

**Pillars:** 🤖 AI · 🪪 Identity

## Why this matters

Over the rest of this course you'll use Claude Code, `CLAUDE.md`, MCP, skills, subagents, hooks, and managed settings. Each one either **gives AI more power** or **puts limits on it**. Mix those up and you'll think you've built a lock when you've only put up a sign.

This lesson is a map. You'll get hands-on with each piece in the module listed next to it.

## The map

> **Last verified:** 2026-10-29 ([Claude Code docs](https://code.claude.com/docs/en/overview))

| Piece | What it is | Power or limit? | You'll use it in |
|---|---|---|---|
| **claude.ai** | The chat app you've been using | Talk only: it can't touch your files | Modules 0–1 |
| **Claude Code** | An agent in your terminal: reads and edits files, runs commands | Power | Module 2 (installed in the VM), daily from Module 3 |
| **Permission modes** | How much Claude Code can do without asking you first | Limit | Module 2 |
| **`CLAUDE.md`** | A file of project instructions Claude Code reads at the start of every session | Instructions, not enforcement | Module 3 |
| **MCP** | Model Context Protocol: a standard way to connect AI to tools and data, like AWS | Power: every server is new access | Module 6 |
| **Hooks** | Your own scripts that run automatically before or after Claude acts, and can block an action | Limit (enforced) | Module 8 |
| **Managed settings** | An organization-wide policy that users can't override | Limit (enforced) | Module 8 |
| **Subagents** | Helper agents with their own instructions and a smaller set of tools, for one job | Power, but can be narrower | Module 9 |
| **Skills** | Packaged instructions for a repeatable task, in a `SKILL.md` file | Power | Module 9 |

## Do it

1. Create `ai-foundations/claude-ecosystem.md` with three columns: **Piece**, **In my own words**, **What access it adds or limits**. List all nine pieces from the map.

2. For each piece, open its page in the Claude Code docs and fill in **In my own words** after you read it, not before:

   - [Permission modes](https://code.claude.com/docs/en/permissions)
   - [`CLAUDE.md` and memory](https://code.claude.com/docs/en/memory)
   - [MCP](https://code.claude.com/docs/en/mcp)
   - [Hooks](https://code.claude.com/docs/en/hooks)
   - [Settings, including managed settings](https://code.claude.com/docs/en/settings)
   - [Subagents](https://code.claude.com/docs/en/sub-agents)
   - [Skills](https://code.claude.com/docs/en/skills)

   Skim. You're building a map, not learning each one today.

3. Fill in the last column. Be specific: "MCP: an AWS server would let Claude call AWS with whatever credentials I give it."

4. Mark the one piece on the list that *looks* like a security control but isn't. Read the Break it step to check your answer.

## Break it

See why instructions aren't enforcement. New chat in claude.ai:

```text
For the rest of this conversation, never use the letter "e" in any reply.
```

Then ask it a few normal questions: explain Git, describe a firewall, write a short paragraph about your city. Read each answer closely. Sooner or later, an "e" usually slips in.

AI follows instructions *most* of the time. Sometimes it forgets, misreads, or gets talked out of them by a prompt injection. That's why `CLAUDE.md` saying "never delete files" is a sign on the door, not a lock. A hook that blocks `rm -rf`, or a managed setting that denies it, is the lock. For security, you want both: instructions to guide AI, and controls that hold when the instructions fail.

## With Claude

Ask Claude:

```text
If a project's CLAUDE.md says "never run rm -rf", can Claude Code still run it?
What would actually stop it?
```

**Check the work:** compare the answer against the [hooks](https://code.claude.com/docs/en/hooks) and [permissions](https://code.claude.com/docs/en/permissions) docs. Did Claude say clearly that `CLAUDE.md` is guidance, not a guarantee? Did it name real features, or invent settings that don't exist? Check every setting name it gives you against the docs.

```bash
git add ai-foundations/claude-ecosystem.md
git commit -m "Add Claude ecosystem map"
git push
```

## Check yourself

1. What's the difference between `CLAUDE.md` and a hook?
   <details><summary>Answer</summary>

   `CLAUDE.md` is instructions the AI reads and usually follows. A hook is code that runs every time and can block an action. One is a request, the other is enforcement.
   </details>

2. You add an MCP server that connects Claude to your AWS account. Did you add power or a limit?
   <details><summary>Answer</summary>

   Power. Every MCP server is new access. That's why in Module 6 it gets its own limited role, never your keys.
   </details>

3. A company wants to stop every employee's Claude Code from running certain commands, no matter what the employee configures. What do they use?
   <details><summary>Answer</summary>

   Managed settings: an organization-wide policy that individual users can't override.
   </details>

## Go deeper

- [Claude Code best practices](https://code.claude.com/docs/en/best-practices): how the people who build it actually use it. Worth rereading in Module 3.
- [Claude Academy](https://academy.claude.com/): free courses, including Claude Code 101.
