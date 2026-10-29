# Module 1: AI Foundations

**Pillars:** 🤖 AI

> 🚧 **Outline.** Lessons are being written. The checklist and plan below are final.

## Why this module matters

You'll use AI in every module after this one, so you need to know how to drive it, and how to keep it from hurting you. The course's stance on AI fits in two sentences:

> **Don't put AI into your world. Give AI parts of your world, explicitly.**
>
> Treat AI like a very hard-working, very fast junior engineer. Same rules as any new hire: least privilege, access controls, network controls, segmentation. Limit the blast radius, and wherever you can, put it in a box.

## You're ready to move on when…

- [ ] You can explain what an LLM is, and why it can be confidently wrong
- [ ] You can pick a small, mid-tier, or top model (and when to turn on extended thinking) for a given task, and say why
- [ ] You can write a prompt with context, constraints, and an example, and get a better answer than a one-liner
- [ ] You know what never goes into an AI tool: secrets, customer data, anything you don't own
- [ ] You can explain prompt injection with an example
- [ ] You can name the top three risks in the OWASP Top 10 for LLM Applications
- [ ] You can describe the "AI in a box" philosophy and one control for each layer of the box

## Lessons (planned)

1. **What AI is and isn't.** Hallucinations, and why "check the work" is step 3 of every lesson. *Break it:* get Claude to confidently invent a fake Linux command.
2. **Models and thinking modes.** A decision rule, not a version list: small/fast for quick lookups and bulk work, mid-tier as the daily default, top model with extended thinking for hard debugging, architecture, and security review.
3. **Prompting that works.** Context, constraints, examples, and asking for a plan first.
4. **What never goes in.** Secrets, personal data, customer data. "Free AI is often paid for with your data."
5. **AI in a box.** The philosophy, and the boxes you'll build in this course: the VM (Module 2), containers (Module 5), network controls (Modules 4, 6), its own IAM role (Module 7), hooks and managed settings (Module 8), and audit logs (Module 9).
6. **The OWASP Top 10 for LLM Applications.** Introduced here, applied in Module 8.
7. **The Claude ecosystem map.** Claude Code, `CLAUDE.md`, MCP, skills, subagents, hooks, managed settings: what each is, and the module where you'll use it.

> **Last verified:** 2026-10-27 — the [OWASP Top 10 for LLM Applications 2026](https://genai.owasp.org/initiatives/top-10-for-llm-and-genai/) is the current edition; prompt injection, sensitive information disclosure, and excessive agency are the top three.

## Practice

- **Quiz:** model choice scenarios, spotting secrets in a prompt, prompt injection examples
- **Project:** `ai-usage-policy.md` in your portfolio: your personal rules for using AI, in your own words

## Getting set up

This module works on the **free Claude plan** at [claude.ai](https://claude.ai). You'll add Claude Code with a **Claude Pro** plan at Module 3. Can't pay? Use the [free AI path](../appendix/free-ai-path.md).

## Dig Deeper

- [OWASP Top 10 for Agentic Applications](https://genai.owasp.org/): risks once AI has tools and memory. Claude Code is an agent, so this is the list to read next.
