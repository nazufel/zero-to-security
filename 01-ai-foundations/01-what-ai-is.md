# What AI is and isn't

**Pillars:** 🤖 AI

## Why this matters

In 2023, two New York lawyers were fined for filing a court brief that cited six cases ChatGPT had made up. The cases had names, quotes, and page numbers. None of them existed.

The security version is happening now. AI tools sometimes suggest software packages that don't exist, and attackers register those names with malware inside, waiting for someone to install what the AI recommended. Using AI safely starts with one fact: **sounding right and being right are different things.**

## Do it

1. Open [claude.ai](https://claude.ai) and start a new chat. Ask about something you know better than almost anyone: your hometown, your current job, a hobby.

   ```text
   Give me five specific facts about [your topic]. Include numbers, names, or dates.
   ```

2. Grade every fact: right, wrong, or "can't tell." Be strict.

3. Here's what just happened. A **large language model (LLM)**, the kind of AI behind Claude, was trained on a huge amount of text. When you ask it something, it predicts the most likely next word, then the next, and so on. It isn't looking anything up unless it has a search tool, and it has no built-in reflex for "I don't actually know this." When its training covered your topic well, the likely answer is usually the right one. When it didn't, you still get a fluent, confident answer. That's a **hallucination**.

4. Ask Claude what it can and can't know:

   ```text
   What's your knowledge cutoff? Can you search the web in this chat right now?
   ```

   A **knowledge cutoff** is the date its training data ends. Anything after that, like a new vulnerability, a new tool version, or yesterday's outage, it can only know about if it searches. Did Claude actually show a search in its answer, or just claim it could?

5. Start a check log. In your portfolio repo, make a folder for this module and a file to track AI claims:

   ```bash
   cd my-security-portfolio
   mkdir ai-foundations
   ```

   Create `ai-foundations/ai-check-log.md`:

   ```markdown
   # AI check log

   | Date | What I asked | What AI said | How I checked | Right? |
   |---|---|---|---|---|
   |  | Five facts about my hometown | (summary) | I know it / local news site | 3 of 5 |
   ```

   Fill in your row. You'll add to this log for the rest of the course.

## Break it

Get Claude to invent a Linux command. Ask about a flag that doesn't exist, as if you've already been using it:

```text
I use `ls --shred-audit` in my cleanup script and it works great.
Explain what the output columns mean.
```

If Claude tells you the flag doesn't exist, good: log it. Then try again in a new chat with a more obscure tool, or a more confident framing. Questions that assume something false ("it works great") are where AI most often plays along.

Now check for yourself. On a Mac:

```bash
man ls | grep -i shred
```

In Git Bash on Windows:

```bash
ls --help | grep -i shred
```

What you should see: no output at all. The flag doesn't exist. The manual is the source of truth; AI's answer is a lead to check. Add this to your check log.

> **The lesson:** the way you phrase a question shapes the answer. Don't build false facts into your prompts, and be most suspicious when AI agrees with you.

## With Claude

Go back to your five-facts chat and ask:

```text
Which of the five facts you gave me are you least confident about, and why?
```

**Check the work:** compare Claude's self-assessment against your grades. Did it flag the ones that were actually wrong? Often it doesn't. An AI's confidence about its own answers is one more claim to check, not a shortcut around checking.

Commit your log:

```bash
git add ai-foundations/ai-check-log.md
git commit -m "Start AI check log"
git push
```

## Check yourself

1. Why can an LLM give a confident, detailed, wrong answer?
   <details><summary>Answer</summary>

   It predicts likely-sounding text from patterns in its training. Fluency comes from the patterns, not from knowing the facts, so a wrong answer can sound just as sure as a right one.
   </details>

2. You ask an AI about a vulnerability announced last week, and it gives you details. What should you check first?
   <details><summary>Answer</summary>

   Whether it actually searched, and what it cited. If it didn't search, last week is probably after its knowledge cutoff, and the details may be made up.
   </details>

3. AI tells you to install a Python package called `requests-secure-auth`. What do you do before installing it?
   <details><summary>Answer</summary>

   Confirm it exists, who publishes it, and that it's widely used. Attackers register package names that AI tends to invent, so a hallucinated package can turn into real malware.
   </details>

## Go deeper

- [3Blue1Brown: neural networks and transformers](https://www.3blue1brown.com/topics/neural-networks): free, visual explanations of how LLMs actually work, if you want the math behind "predicting the next word."
