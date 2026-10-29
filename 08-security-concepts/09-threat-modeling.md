# Threat modeling with STRIDE

**Pillars:** ☁️ Cloud · 🪪 Identity · 🤖 AI

## Why this matters

Everything so far has been fixing problems you were shown. **Threat modeling** is finding them yourself, before an attacker does, by asking a simple question about every part of a system: **what could go wrong here?** It's the design review that catches "anyone can delete anyone's notes" before it ships, and it's **OWASP A06, Insecure Design**: flaws no scanner can find, because the code does exactly what it was designed to do.

**STRIDE** is a checklist that keeps you from only thinking of the threats you already know.

## STRIDE

| Letter | Threat | Breaks | The question | Example in the notes app |
|---|---|---|---|---|
| **S** | **Spoofing** | Authentication | Can someone pretend to be someone else? | Forging a signed `DELETE` request |
| **T** | **Tampering** | Integrity | Can someone change data or code they shouldn't? | Editing another user's note |
| **R** | **Repudiation** | Accountability | Can someone do something and deny it? | Deleting notes with no record of who |
| **I** | **Information disclosure** | Confidentiality | Can someone see what they shouldn't? | Reading the table through a misconfigured role |
| **D** | **Denial of service** | Availability | Can someone take it down? | Flooding the API |
| **E** | **Elevation of privilege** | Authorization | Can someone get more access than they should? | A developer deploying code that runs as the function's role |

## Do it

1. **Start from your diagram.** Open the architecture diagram from the [Module 6 project](../06-cloud-aws/project.md). Mark every **trust boundary**: a line where data crosses from something you trust less to something you trust more. The internet to CloudFront. The browser to API Gateway. API Gateway to Lambda. Lambda to DynamoDB. Your laptop to AWS. Claude to AWS.

2. **Walk STRIDE across each boundary.** Create `security/threat-model.md`:

   ```markdown
   # Notes app threat model

   | # | Boundary | STRIDE | Threat | Current control | Gap? | Fix / accept |
   |---|---|---|---|---|---|---|
   | 1 | Internet → API | D | Flood of requests | Throttle 5/s, burst 10 | Per-API, not per user | Accept for a demo; WAF rate rules at work |
   | 2 | Internet → API | T | Anyone can post a note | Input validation | No auth on POST | Accept (public demo), document it |
   | 3 | Internet → API | R | Who posted a note? | None | No identity on POST | |
   | ... | | | | | | |
   ```

   Aim for at least 15 rows, and at least one per letter. Use what you've built: many of your answers in "current control" will be lessons from Modules 6 to 8. The "Gap?" column is where the value is.

3. **Rank the gaps.** For each gap, rate likelihood and impact as low, medium, or high. Fix the high-high ones; document the rest as accepted risks, with a reason. Like Checkov's skip list in lesson 14, **accepting a risk on purpose, in writing, is a valid outcome.** Not knowing about it isn't.

4. Commit `threat-model.md`. You'll compare it with Claude's version next.

## Break it

Find the threat the design hides. Look at row 3 in the example: anyone can post a note, with no identity. Now combine that with something from [Module 1](../01-ai-foundations/06-owasp-llm-top-10.md): a note's text ends up in places an AI might read, like an export someone hands to Claude to summarize. What's the threat, which STRIDE letter is it, and which boundary did you miss?

<details><summary>One answer</summary>

**Prompt injection**, stored in a note, waiting for an AI to read it. It's **Tampering** (with the AI's instructions) that can lead to **Elevation of privilege** (the AI acting with its own permissions on the attacker's behalf). The missed boundary is **data → AI**: the AI trusts what it reads. The controls are the ones you built in Modules 6 and 7: the AI's view-only roles mean an injected instruction can't do much. Lesson 11 tests this.
</details>

## With Claude

Now have Claude do the same exercise, **without** seeing yours:

```text
Read notes-app/ (code, infrastructure, and diagram). Threat-model it with
STRIDE: list trust boundaries, then threats per boundary with current
controls and gaps. Rank the top five gaps by likelihood and impact.
```

**Check the work** by comparing the two models row by row, in a new section of `threat-model.md` called **"Claude's model vs. mine"**:

- Threats Claude found that you missed. Are they real? Check each against the code.
- Threats you found that Claude missed. (Often: the ones specific to your choices, like the developer-deploys-code escalation from [Module 7](../07-identity/03-groups.md).)
- "Controls" Claude claims exist. Do they? A threat model that lists a WAF you never built is worse than none, because it says you're protected.
- Its top five. Do you agree with the order? Why or why not?

This is the most important review you'll do of AI output in the course, because a threat model is only useful if it's **true about your system**.

## Check yourself

1. What does each letter of STRIDE stand for?
   <details><summary>Answer</summary>

   Spoofing, Tampering, Repudiation, Information disclosure, Denial of service, Elevation of privilege.
   </details>

2. What's a trust boundary?
   <details><summary>Answer</summary>

   A point where data or requests cross from a less-trusted part of a system to a more-trusted one. Threats cluster there.
   </details>

3. Why can't a scanner find insecure design?
   <details><summary>Answer</summary>

   The code does what it was designed to do. The flaw is in the design itself, like a route that should require identity and doesn't. Only reasoning about the design finds it.
   </details>

## Go deeper

- [OWASP Threat Modeling Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Threat_Modeling_Cheat_Sheet.html)
- [The Threat Modeling Manifesto](https://www.threatmodelingmanifesto.org/): short, and the best summary of the mindset.
