# Keep practicing

## Why this matters

Job hunting can take months. Skills fade faster than that if you stop using them, and "what have you been working on lately?" is a common interview question. Keeping a steady practice going keeps you sharp, gives your portfolio a fresh date, and gives you something new to talk about in every interview.

It also matters for the job itself. Security changes constantly. The people who do well are the ones who keep learning after they're hired.

## Do it

1. **Pick a rhythm you'll keep.** Three short sessions a week beats one long one you skip. Write your plan in `career/practice-plan.md`:

   ```markdown
   | Day | 45 minutes on |
   |---|---|
   | Mon | One lab or challenge |
   | Wed | Interview practice (one mock interview section, out loud) |
   | Sat | One portfolio improvement or Dig Deeper topic |
   ```

2. **Choose free labs that match your target role.** All of these are free, built to be attacked, and legal ([Module 0](../00-start-here/02-ethics-and-the-law.md)):

   | For | Lab | What it practices |
   |---|---|---|
   | Everyone | [OverTheWire](https://overthewire.org/wargames/) | Linux, step by step. Go past Bandit level 15. |
   | Everyone | [picoCTF](https://picoctf.org/) | Beginner capture-the-flag challenges, all year |
   | SOC | [CyberDefenders](https://cyberdefenders.org/) (free labs) | Blue-team investigations: logs, packet captures, endpoints |
   | SOC | [Malware-Traffic-Analysis.net](https://www.malware-traffic-analysis.net/) | Real packet captures with exercises |
   | Cloud | [flaws.cloud](http://flaws.cloud/) and [flaws2.cloud](http://flaws2.cloud/) | AWS mistakes, attacker and defender paths |
   | Web | [OWASP Juice Shop](https://owasp.org/www-project-juice-shop/) | The OWASP Top 10, hands-on, in Docker on your VM |

3. **Write up what you learn.** After each lab, add a short writeup to your portfolio: what the challenge was, how you solved it, and what you'd watch for at work. **Don't publish solutions** to labs that ask you not to; write about the concept instead. Writeups keep your portfolio active and give you fresh interview stories.

4. **Follow the field, lightly.** Pick one or two free sources and skim them weekly: CISA's [Known Exploited Vulnerabilities](https://www.cisa.gov/known-exploited-vulnerabilities-catalog) list (what attackers are using right now), and one security news source or podcast you enjoy. When a big incident hits the news, try to map it: which OWASP risk, which ATT&CK tactics, which control from this course would have helped?

5. **Give back.** Answer a beginner's question in a community, or [open an issue](../../../issues/new/choose) on this course when something confused you or a fact is out of date. Explaining things is the fastest way to find the gaps in your own understanding, and it's visible proof you can communicate.

## Break it

Imagine it's three months from now, and an interviewer asks, "What have you been working on since you finished your course?" Answer it out loud, honestly, as things stand today.

If the honest answer is "applying to jobs," you have a gap that's easy to close. Write the answer you **want** to be able to give in three months, in `practice-plan.md`, and work back to what you'd need to do each week to make it true.

## With Claude

Ask Claude Code:

```text
Here's my target role and my portfolio README. Suggest a 4-week practice
plan using only free labs, at 3 sessions of 45 minutes a week, that would
fill my biggest gaps for that role. Include one writeup per week.
```

**Check the work:** check that every lab it suggests is real, free, and legal to attack, by visiting each site yourself. AI sometimes suggests labs that have closed, moved behind a paywall, or don't exist. And check that the plan targets **your** gaps, not a generic list. Adjust it, then commit it.

## Check yourself

1. Why keep practicing while you job-hunt?
   <details><summary>Answer</summary>

   Skills fade, your portfolio stays current, and you always have a fresh answer to "what have you been working on lately?"
   </details>

2. What makes a lab safe and legal to practice on?
   <details><summary>Answer</summary>

   It's built to be attacked, by people who explicitly invite you to. Everything else needs written permission.
   </details>

3. Why write up what you learn?
   <details><summary>Answer</summary>

   It keeps your portfolio active, cements what you learned, and gives you specific stories for interviews.
   </details>

## Go deeper

- [Dig Deeper](../dig-deeper/): every topic is free, and each one is a portfolio entry.
