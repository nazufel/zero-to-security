# "Aren't you worried AI will replace you?"

**Pillars:** 🤖 AI

## Why this matters

You'll be asked this, in some form, in almost every interview: "How do you feel about AI?" "Won't AI do this job soon?" "How do you use AI at work?" It's not small talk. The interviewer wants to know whether you'll be a person who uses AI well, one who uses it carelessly, or one who refuses to use it at all.

Your answer is the reason this course exists. You don't need to invent one. You need to say it clearly.

## Do it

1. **Write your answer** in `career/ai-answer.md`. Use your own words, but cover these three points, with an example from your own work for each:

   - **AI makes me faster.** What you use it for, specifically. ("I used Claude Code to add a detection mode to my log tool, and to draft postmortems from incident evidence.")
   - **I check its work.** How you know when it's wrong, with a real example. ("It once gave me an IAM policy with `s3:ListBucket` on the object ARN instead of the bucket, which would have silently granted nothing. I test every policy in the simulator now.") Use a real entry from your [AI check log](../01-ai-foundations/01-what-ai-is.md).
   - **I keep it in a box.** How you limit what it can do. ("It runs in a VM, has its own view-only AWS role, and my managed-settings policy blocks it from my credentials. I designed it assuming it'll sometimes be fooled by prompt injection.")

2. **Then answer the actual worry**, honestly. The course's view, from the [README](../README.md): attackers are using AI to find and exploit weaknesses faster, and defenders are using AI to fight back. Someone has to point those tools at the right problems, check their work, and make the call when it matters. That's a person who knows the fundamentals **and** knows how to work with AI. Say why that's you, in one or two sentences, with proof.

3. **Say it out loud**, in under 90 seconds. Record it. It should sound calm and specific, not defensive and not hyped.

4. **Prepare for the follow-ups:**

   - "What should AI never do in security?" ([Module 9, lesson 13](../09-incident-response/13-ai-in-the-soc.md): decisions with real consequences, anything about a person.)
   - "What's prompt injection?" (Your own example from [Module 8, lesson 11](../08-security-concepts/11-securing-ai.md).)
   - "Would you paste customer data into ChatGPT?" ([Module 1, lesson 4](../01-ai-foundations/04-what-never-goes-in.md).)
   - "How would you roll out an AI coding tool safely to a team?" (Your managed-settings policy from [Module 8, lesson 12](../08-security-concepts/12-ai-in-a-box.md).)

## Break it

Try the two answers that lose the job.

The **hype answer:** "AI is amazing, I use it for everything, it writes most of my code." Read it as a security manager. What do you hear? Someone who might paste secrets into a chatbot and ship code they haven't read.

The **fear answer:** "I try not to use it much; I think it's risky and I prefer to understand things myself." Read it as a manager whose team uses AI daily. What do you hear? Someone who'll be slower than the team, and who can't help secure tools they won't touch.

Your answer from step 1 sits between them, and it's the one every security team is hiring for right now. Write one sentence in `ai-answer.md` on why each wrong answer loses.

## With Claude

Ask Claude to push back:

```text
I'm interviewing for a [your target role]. Ask me "Aren't you worried AI
will replace you?" After my answer, play a skeptical interviewer: push back
twice on the weakest part. Then tell me if my answer would make you more or
less likely to hire me, and why.
```

**Answer out loud, then type it.** **Check the work:** an AI judging answers about AI is a little circular. Notice whether its pushback is the kind a real security manager would raise ("How do you know it didn't make a mistake you missed?") or generic. And notice whether it rewards hype. If it does, that's a data point for your AI check log, not for your answer.

## Check yourself

1. What three things should your answer cover?
   <details><summary>Answer</summary>

   AI makes you faster (with specifics), you check its work (with a real example), and you keep it in a box (with your controls).
   </details>

2. Why does the hype answer worry a security manager?
   <details><summary>Answer</summary>

   It sounds like someone who'd trust AI output without checking it and share data with it carelessly: exactly the risks the team has to manage.
   </details>

3. Why does the fear answer also lose?
   <details><summary>Answer</summary>

   Teams use AI daily. Someone who avoids it will be slower, and can't help secure tools they don't understand.
   </details>

## Go deeper

- [The AI vs AI Battle for the Internet](https://open.spotify.com/episode/6u7ZO8Elg46mWjdu6jXzeU) (The AI Daily Brief): the episode that inspired this course. Listen again, now that you can follow every part of it.
