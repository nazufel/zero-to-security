# Getting unstuck

## Why this matters

You're going to get stuck. Constantly. That's not a sign you're bad at this; it's what the job is. Working engineers spend a big part of every day stuck on something.

People rarely quit learning because the material is too hard. They quit because they get stuck, feel alone, and stop. This lesson is your plan for when that happens.

## The stuck playbook

Work down this list in order.

### 1. Read the error. All of it.

Most beginners glance at a wall of red and panic. Slow down. The answer is often in the message itself.

- **Read the last line first.** In Python, the last line of an error is the actual problem; everything above is how the program got there.
- **Look for a file name and line number.** That's where to look.
- **Copy the exact text.** You'll need it for every step below.

### 2. Check the obvious

Typos. Wrong folder (`pwd` tells you where you are). A file you forgot to save. A command that needs `sudo`. These cause more errors than anything clever.

### 3. Explain it out loud

Say what you're trying to do, what you expected, and what happened instead. To a friend, a pet, or a rubber duck. You'll often hear the mistake as you say it. Engineers really do this; it's called **rubber duck debugging**.

### 4. Ask Claude for a hint, not the answer

```text
I'm learning. Don't give me the fix. Explain what this error means
and give me one hint about where to look.

[paste the exact error and the command you ran]
```

When you're learning, the fix isn't the point. Understanding is. You can always ask for the full answer after you've tried.

### 5. Follow the 20-minute rule

Stuck for 20 minutes with no progress? Ask a human. Stuck for 2 hours? You waited too long.

### 6. Ask a human a good question

A good question gets answered fast. A vague one gets ignored. Include:

```markdown
**What I'm trying to do:**
**What I ran:** (exact command)
**What I expected:**
**What happened:** (exact error, copied)
**What I've tried:**
```

Notice anything? It's the same shape as a good ticket from the [last lesson](04-tickets-and-documentation.md). Same skill.

You can ask in this course's [GitHub issues](../../../issues/new/choose), or in any beginner-friendly security or Linux community.

### 7. Walk away

Seriously. Sleep on it. A surprising number of bugs are obvious the next morning.

## Do it

Let's practice on a real error. Run this in your terminal:

```bash
cd my-security-portfolioo
```

(Yes, with the typo.)

1. Read the error. What is it telling you?
2. Use `pwd` and `ls` to work out where you are and what's actually there.
3. Fix it.

Now write a stuck log. Add a file called `stuck-log.md` to your portfolio:

```markdown
# Stuck log

| Date | What I was stuck on | What fixed it | What I learned |
|---|---|---|---|
|  | `cd` said "No such file or directory" | Typo in the folder name | Read the error; check spelling first |
```

Add a row every time you get properly stuck during this course. It becomes a record of how much you've learned, and great material for "tell me about a time you solved a hard problem" in interviews.

```bash
git add stuck-log.md
git commit -m "Start stuck log"
git push
```

## Break it

Ask Claude for help with *only* this:

```text
my code doesn't work
```

See how little it can do? Now give it the full good-question template. Same lesson for humans: the quality of the answer depends on the quality of the question.

## With Claude

Next time you're genuinely stuck in this course, try the hint prompt from step 4 *before* asking for the answer.

**Check the work:** after you fix it, could you explain the fix to someone else without looking? If not, you copied it, you didn't learn it. Ask Claude to quiz you on it.

## Check yourself

1. Python prints 15 lines of error. Which line do you read first?
   <details><summary>Answer</summary>

   The last one. It names the actual error. The lines above trace how the program got there.
   </details>

2. You've been stuck for 25 minutes. What now?
   <details><summary>Answer</summary>

   Ask a human, using the good-question template.
   </details>

## Go deeper

- [How to Ask Questions the Smart Way](http://www.catb.org/~esr/faqs/smart-questions.html): old and blunt, but still the classic on asking technical questions.
