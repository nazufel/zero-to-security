# Style Guide

Read this before you write or edit a lesson. The whole course depends on it.

## The one rule

**Learners build skills and muscle memory by doing.** Text exists to set up the doing and explain the *why*. If a learner reads for more than a minute without typing something, the lesson is broken.

## Lesson rules

- **Hands on the keyboard within the first screen.** No more than ~3 short paragraphs before the first command.
- **Every concept gets a "why" in 2–3 sentences.** Make it real: a breach, an outage, a ticket they'll get on day one. The why is the most important part of the lesson.
- **Learn by breaking.** Most lessons have a "Break it" step. The error message teaches more than the explanation.
- **Short, plain, second person.** "You", not "the learner". Define jargon the first time you use it.
- **Engaging, never cute.** No memes, no forced jokes. Interesting comes from real stories.
- **Repetition is a feature.** Bring commands back in later modules without re-explaining them.
- **Deep dives are optional links.** Never required reading.
- **Opinionated.** Pick one tool and say why. Mention alternatives in one line, at most.
- **Free.** Every resource, tool, and link must be free. The only exception is Claude Pro, which is always paired with the [free AI path](appendix/free-ai-path.md).

## Lesson template

Copy this for every lesson.

````markdown
# Lesson title

**Pillars:** ☁️ Cloud · 🪪 Identity · 🤖 AI  *(only the ones that apply)*

## Why this matters
Two or three sentences. A real consequence.

## Do it
1. Numbered steps.
   ```bash
   command here
   ```
   What you should see:
   ```
   expected output
   ```
2. Next step.

## Break it
Cause a failure on purpose. Show the error. Explain in one or two sentences what it's telling you.

## With Claude
Do the same task with Claude Code. Always end with what to **check** in Claude's work.

> **Free AI path:** one line pointing to the OpenCode equivalent, or "read along".

## Check yourself
1. Question?
   <details><summary>Answer</summary>

   Answer, with a one-line why.
   </details>

## Go deeper
- [Optional link](https://example.com): one line on why it's worth reading.
````

## Module README template

Every module folder has a `README.md` with:

1. **Why this module matters**: one short paragraph
2. **You're ready to move on when…**: a checklist of skills, not topics. ("You can SSH into your VM with a key", not "SSH")
3. **Lessons**: an ordered list of links
4. **Quiz, challenges, and project**: links
5. **Dig Deeper**: optional extras

**Every lesson must serve at least one box on the checklist.** If it doesn't, cut it.

## The three-step pattern for AI

Every module teaches a skill three ways:

1. **By hand**: so you understand it
2. **With Claude**: so you can do it fast
3. **Check the work**: so you catch AI's mistakes

Never let Claude's output go unchecked in a lesson. Catching AI mistakes is a hireable skill.

## Cloud lessons: Console → Code → Claude

1. **Console:** click through once to see the service
2. **Code:** define it in OpenTofu
3. **Claude:** have Claude extend it, then review the diff and the `tofu plan`

## Fast-moving facts

Anything that can change (prices, free tiers, model names, free-model lists, tool versions) gets a dated note:

```markdown
> **Last verified:** 2026-10-27
```

Prefer teaching a decision rule over a specific version. "Use the top model for hard debugging" ages better than a model name.

## Quizzes

- Answers go in `<details>` tags so they're hidden until clicked.
- Every answer includes a one-line *why*.
- Test skills, not trivia. "What does this command output?" beats "What year was Linux released?"

## Formatting

- Code blocks always name the language (`bash`, `python`, `hcl`, `json`).
- Commands learners type go in code blocks. Output goes in a separate block.
- One idea per paragraph. Paragraphs of 1–3 sentences.
- Use tables for comparisons, lists for steps.
