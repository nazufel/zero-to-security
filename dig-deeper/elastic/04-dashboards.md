# Dashboards

**Pillars:** ☁️ Cloud

## Why this matters

A dashboard is how a SOC sees its world at a glance: is today normal? Is something spiking? A good one answers a few specific questions in a few seconds. A bad one is twenty colorful charts nobody reads. You'll build one that answers the questions you've asked by hand all course, and learn to tell the difference.

## Do it

1. **Decide the questions first.** Before you build anything, write in `elastic/notes.md` the four questions an analyst opening this dashboard in the morning should be able to answer. For example:

   - Who is getting denied in AWS, and is it more than usual?
   - Which identities are acting from new IP addresses?
   - Which IPs are failing SSH logins, and did any get in?
   - What happened, minute by minute, in the last hour?

2. **Build it.** Open **Dashboards → Create dashboard**. For each question, add one panel (**Create visualization**, which opens Lens, or **Add panel → ES|QL** to reuse a query from lesson 3):

   | Question | Panel |
   |---|---|
   | Who's being denied? | Bar chart: count of events where `errorCode` exists, by `userIdentity.arn` |
   | From where? | Table: `userIdentity.arn` and `sourceIPAddress`, with counts |
   | SSH failures and successes | Your step 4 ES|QL query from lesson 3, as a table |
   | Over time | Line chart: count of CloudTrail events over time, split by `errorCode` exists or not |

   Name it **"SOC morning check"** and save.

3. **Read it like an analyst.** Set the time range to "Last 1 hour." In under 30 seconds, answer your four questions from the dashboard alone. The `ci-deploy` burst should stand out on every panel. If it doesn't, the panel isn't answering its question; fix it.

4. **Export it** for your portfolio: **Stack Management → Saved objects**, select the dashboard, **Export**. Commit the `.ndjson` file to `elastic/`, with a screenshot.

## Break it

Make the dashboard worse in the most common way: add "useful" panels. A pie chart of `eventSource`. A word cloud of `eventName`. A count of all events. A map. Then do the 30-second test again.

It's slower, and the important panel is now competing with noise. Pie charts of normal activity tell nobody anything; a total event count that's "big" means nothing without a baseline. Every panel on a SOC dashboard should answer a question that leads to an action. Delete the extras, and write in your notes the rule you'd use to decide whether a panel stays.

## With Claude

Ask Claude Code:

```text
I'm a SOC analyst with CloudTrail and SSH auth logs in Elastic. Suggest
5 dashboard panels that would help me spot an attack in progress. For each,
the question it answers and the action I'd take if it looks wrong.
```

**Check the work:** does every panel have a real action attached ("escalate," "check this identity's other calls"), or are some just "for visibility"? Can each be built from the fields you actually have? A panel that needs a field you don't have (like geolocation of IPs, or user department) means more ingestion work first. Pick the one you like best and build it.

## Check yourself

1. What should you decide before building any dashboard?
   <details><summary>Answer</summary>

   The specific questions it must answer, and what action each answer leads to.
   </details>

2. Why is "total number of events" usually a weak panel?
   <details><summary>Answer</summary>

   A number with no baseline or context doesn't tell you whether anything is wrong, or what to do.
   </details>

3. What's the 30-second test?
   <details><summary>Answer</summary>

   Open the dashboard and answer its questions from it alone, in 30 seconds. If you can't, the dashboard isn't doing its job.
   </details>

## Go deeper

- [Kibana dashboards](https://www.elastic.co/docs/explore-analyze/dashboards)
