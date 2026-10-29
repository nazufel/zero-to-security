# Tickets and documentation

## Why this matters

In every one of the target jobs, your work lives in tickets. A ticket is how a problem gets reported, tracked, handed off, and closed. A bad ticket wastes hours: the next person has to chase you down to find out what you meant. A good ticket lets anyone pick up where you left off, even at 3 a.m. during an incident.

Hiring managers judge your writing from day one. This is the cheapest skill in the course to learn and one of the most noticed.

## The four kinds of ticket

| Type | What it is | Example |
|---|---|---|
| **Incident** | Something is broken or under attack *right now* | "Email is down for the whole office" |
| **Service request** | Someone needs something normal | "New hire needs a laptop and accounts" |
| **Problem** | The root cause behind repeat incidents | "Why does email go down every Monday?" |
| **Change** | A planned change to a system | "Upgrade the email server Saturday at 10 p.m." |

Getting the type right decides who handles it and how fast.

## What every good ticket has

```markdown
**Summary:** One line. What's wrong, for whom.
**Impact:** Who's affected and how badly.
**Steps to reproduce / what happened:** Numbered, specific.
**Expected:** What should happen.
**Actual:** What happens instead. Exact error messages, copied, not paraphrased.
**What I've tried:** So nobody repeats it.
**Next step / status:** What happens now, and who owns it.
```

## Do it

Here's a real-world-style bad ticket:

> **Subject:** broken
> Jordan says the thing isn't working again. Can someone look at it?

1. Create `ticket-practice.md` in your portfolio repo.
2. List every question you'd have to ask before you could act on that ticket. Aim for at least five.
3. Now rewrite it as a good ticket using the template above. Invent reasonable details: say Jordan in Accounting can't open the shared drive and gets `Access denied` since this morning.
4. Label it with the right ticket type.
5. Commit and push it:

   ```bash
   git add ticket-practice.md
   git commit -m "Add ticket writing practice"
   git push
   ```

## Break it

Hand your rewritten ticket to a friend or family member who knows nothing about IT. Ask them: "If you were the tech, what would you do first?"

If they can't answer, something's missing. Usually it's the exact error message or what's already been tried.

## With Claude

Paste the *bad* ticket into Claude and ask it to rewrite it as a good one.

**Check the work:** this one matters. Did Claude **invent facts** that weren't in the original, like a specific error message or a time? It probably did. In a real ticket, made-up details send the next engineer down the wrong path. AI is great at structure and terrible at knowing what actually happened. Only you know that.

## Check yourself

1. The VPN went down for everyone at 9 a.m. What ticket type is that?
   <details><summary>Answer</summary>

   Incident. It's broken right now and affecting people.
   </details>

2. The VPN has gone down every Tuesday for a month. What ticket type should someone open?
   <details><summary>Answer</summary>

   Problem. Each outage is an incident, but the repeating pattern needs a root-cause investigation.
   </details>

3. Why copy error messages exactly instead of describing them?
   <details><summary>Answer</summary>

   Exact text can be searched (in logs, docs, or online). "Some kind of permission error" can't.
   </details>

## Go deeper

- [PagerDuty Incident Response docs](https://response.pagerduty.com/): you'll use these in Module 9. Skim the "Being on-call" section now to see why clear writing matters under pressure.
