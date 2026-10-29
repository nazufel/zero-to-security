# Prompting that works

**Pillars:** 🤖 AI

## Why this matters

A vague prompt gets generic advice you can't use. A clear one gets a first draft you can ship after a quick review. You already learned this in [Getting unstuck](../00-start-here/05-getting-unstuck.md): the answer is only as good as the question. AI makes that rule stricter, not looser.

## The five parts of a good prompt

| Part | What it does | Example |
|---|---|---|
| **Context** | Who you are, what the situation is | "I do IT for a 12-person dental office." |
| **Task** | What you want, in one sentence | "Draft a one-page password policy." |
| **Constraints** | Limits and rules | "Plain English. Under 300 words." |
| **Example** | Shows the style or format you want | "Like: 'Use three random words as a passphrase.'" |
| **Output format** | The shape of the answer | "A heading, a bulleted list, then a 2-line section." |

You won't need all five every time. For anything that matters, you'll want most of them.

## Do it

1. New chat in [claude.ai](https://claude.ai). Send a one-liner:

   ```text
   Write a password policy.
   ```

   Skim it. Could you hand it to a receptionist tomorrow?

2. New chat. Now the full version:

   ```text
   Context: I do IT for a 12-person dental office. Staff share front-desk PCs.
   Last year a receptionist typed her email password into a fake login page.

   Task: Draft a one-page password policy for staff.

   Constraints: Plain English, no jargon. Under 300 words. Follow current NIST
   guidance, so no forced password changes on a schedule, only after a
   suspected compromise. Require MFA on email.

   Example of the tone I want: "Use a long passphrase you can remember,
   like three random words."

   Output: A heading, a bulleted list of rules, then a two-line section called
   "If you think your password leaked."
   ```

3. Compare the two answers side by side. Write down three things the second one does that the first doesn't.

4. Now try **plan first**. For bigger tasks, have AI show you its plan before it does the work, so you can fix the direction while it's cheap:

   ```text
   Before you write anything, give me a short plan for the policy and ask me
   up to three questions about anything you'd otherwise have to guess.
   ```

   Answer its questions. Notice that the questions are often things you forgot to say.

5. Save a reusable template as `ai-foundations/prompt-template.md`:

   ```markdown
   # My prompt template

   **Context:**
   **Task:**
   **Constraints:**
   **Example:**
   **Output format:**

   For anything big: "Before you start, give me a plan and ask up to three questions."
   ```

## Break it

Give Claude constraints that can't all be true:

```text
Write a password policy in under 50 words that covers every NIST password
requirement in full detail.
```

Read the answer carefully. Did Claude tell you the constraints conflict, or did it quietly drop one? If it dropped one, which one? When AI can't do everything you asked, it often picks for you without saying so. You need to notice which part went missing.

## With Claude

Paste your dental-office prompt back in and ask:

```text
What's missing from this prompt? What did you have to assume?
```

**Check the work:** does Claude's improved version add "facts" about the office that you never gave it, like the number of computers or which email provider they use? Just like the tickets in Module 0, AI fills gaps with plausible inventions. Keep the structure suggestions; delete any detail that isn't true.

```bash
git add ai-foundations/prompt-template.md
git commit -m "Add prompt template"
git push
```

## Check yourself

1. Name the five parts of a good prompt.
   <details><summary>Answer</summary>

   Context, task, constraints, example, output format. They give AI what a coworker would need to do the job right the first time.
   </details>

2. Why ask for a plan before a big task?
   <details><summary>Answer</summary>

   It's cheaper to fix the direction before the work is done. And AI's questions show you what you forgot to tell it.
   </details>

3. You ask for "a 2-page report under 200 words." What should you check in the answer?
   <details><summary>Answer</summary>

   Which constraint it dropped. They conflict, so AI either has to tell you or silently pick one.
   </details>

## Go deeper

- [Anthropic: prompt engineering overview](https://docs.claude.com/en/docs/build-with-claude/prompt-engineering/overview): the official guide, written for developers but readable.
- [NIST SP 800-63B](https://pages.nist.gov/800-63-4/sp800-63b.html): the US government password guidance from the exercise, if you want to check Claude's policy against the source.
