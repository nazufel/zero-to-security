# Models and thinking modes

**Pillars:** 🤖 AI

## Why this matters

Bigger models are slower and use up your plan's limits faster. At work, they also cost real money per request. Use the top model for everything and you hit your limit by lunch. Use the smallest model for a security review and it misses the bug that matters.

Picking a model is like picking a tool: a screwdriver, a power drill, or a contractor. You need a rule for which one fits the job.

## The decision rule

| Tier | Use it for | Trade-off |
|---|---|---|
| **Small / fast** | Quick lookups, reformatting text, summarizing lots of short items | Fastest and cheapest, but misses subtle things |
| **Mid-tier** | Your daily default: explaining errors, drafting docs, most code | The right balance most of the time |
| **Top model** | Hard debugging, architecture decisions, security review | Slowest and most expensive. Save it for when being wrong is expensive. |

**Start with mid-tier. Go down when the task is simple and repetitive. Go up when the task is hard, or when a wrong answer would cost you.**

**Extended thinking** is a mode where the model works through a problem step by step before it answers. It's slower and uses more of your limit. Turn it on for problems with several steps that depend on each other: puzzles, debugging, "what happens if…" questions. Leave it off for lookups and rewrites, where there's nothing to reason through.

> **Last verified:** 2026-10-29. Claude's model families are **Haiku** (small), **Sonnet** (mid-tier), and **Opus** (top), and new names and versions arrive often. Which ones you can pick, and whether extended thinking is included, depends on your plan, and the free plan may offer fewer choices. The decision rule doesn't change when the names do.

## Do it

1. In [claude.ai](https://claude.ai), open the model picker. Write down which models you can choose and what each one's description says. Find the extended thinking toggle if your plan has one.

2. Solve this by hand first. It's a real SOC skill: logs from different servers often use different time zones.

   ```text
   Server A (UTC):    2026-03-14 02:15  login FAILED for admin
   Server B (UTC-5):  2026-03-13 21:20  login SUCCEEDED for admin
   Server C (UTC+1):  2026-03-14 03:10  admin downloaded customers.csv

   Put these three events in order. Is anything about the order suspicious?
   ```

   <details><summary>Answer</summary>

   Convert everything to UTC first. B: 21:20 UTC-5 is **02:20 UTC**. C: 03:10 UTC+1 is **02:10 UTC**. A is already **02:15 UTC**.

   Order: C (02:10), A (02:15), B (02:20). The download happened *before* the successful login. Either someone already had access another way, or a clock is wrong. Either one is worth investigating.
   </details>

3. Paste the puzzle into Claude with extended thinking **on**, using the mid-tier or top model. Did it get the same answer you did?

4. Create `ai-foundations/model-choices.md` and fill in every row:

   ```markdown
   # Model choices

   | Task | Tier | Extended thinking? | Why |
   |---|---|---|---|
   | Turn 200 lines of messy notes into a bulleted list |  |  |  |
   | Explain an error message from `git push` |  |  |  |
   | Review a login script for security bugs |  |  |  |
   | Summarize 500 short phishing reports into categories |  |  |  |
   | Decide how to split an app across cloud services |  |  |  |
   | Draft a friendly email asking staff to turn on MFA |  |  |  |
   ```

## Break it

Take away the model's room to think. New chat, extended thinking **off**, smallest model you have:

```text
Answer instantly with only the order of events, no working shown.
[paste the three log lines]
```

Try it a few times, in new chats. Forcing an instant answer to a multi-step problem makes mistakes much more likely, on any model. If it got it right every time, notice that you still couldn't tell it was right without doing the math yourself.

## With Claude

Paste your filled-in `model-choices.md` into Claude and ask:

```text
Here's how I'd pick a model tier for each task. Where would you disagree, and why?
```

**Check the work:** where Claude disagrees, decide who's right using the decision rule, not Claude's confidence. And check whether Claude names models that aren't in your picker. Model names change faster than training data, so AI is often out of date about AI.

```bash
git add ai-foundations/model-choices.md
git commit -m "Add model choice worksheet"
git push
```

## Check yourself

1. You need to rename 300 files from one pattern to another. Which tier?
   <details><summary>Answer</summary>

   Small / fast. It's simple and repetitive, and you'll check the result anyway.
   </details>

2. A login keeps failing only on Tuesdays, and you've been stuck for an hour. Which tier, and thinking on or off?
   <details><summary>Answer</summary>

   Top model with extended thinking on. It's a hard, multi-step debugging problem where a wrong guess wastes more time.
   </details>

3. Why not just use the top model with thinking on for everything?
   <details><summary>Answer</summary>

   It's slower, burns through your limits (and money, at work) faster, and gives no benefit on simple tasks.
   </details>

## Go deeper

- [Anthropic: models overview](https://docs.claude.com/en/docs/about-claude/models/overview): the current model lineup and how they compare. Check the date: this page changes often.
