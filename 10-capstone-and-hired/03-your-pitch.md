# Your pitch

## Why this matters

"Tell me about yourself" is the first question in almost every interview, and the one most people answer worst: a rambling walk through their life story. It's also your best chance to set the direction of the whole conversation. Interviewers often ask about whatever you mention first, so a strong 60-second answer means the interview is about your best work.

## Do it

1. **Start from the course's pitch:**

   > *"I can build in AWS, design who gets access to what, and use AI to work faster without making it a security hole."*

   Now make it yours. Rewrite it in your own words, for the role you want. A SOC analyst version might lead with detection and incident response; a help desk version with troubleshooting and explaining security to people. Keep it to one sentence you could say naturally.

2. **Build the 60-second version** around that sentence, in four parts:

   | Part | Time | Content |
   |---|---|---|
   | **Where you're from** | 10 s | Your background, in one line, and what it gave you ("Five years in retail management taught me to stay calm when things break.") |
   | **What you did** | 20 s | Your pitch sentence, and how you built the skills: the projects, not the course |
   | **Proof** | 20 s | One specific project, with one number or result |
   | **Why here** | 10 s | Why this role, at this company |

   Write it in `career/pitch.md`.

3. **Say it out loud.** Record yourself on your phone. Listen back. Does it sound like you, or like you're reading? Cut anything that sounds memorized. Do it five times, until you can say it without notes and it stays under 70 seconds.

4. **Prepare your three stories.** Interviewers will ask follow-ups. Have three short stories ready, each in the **STAR** shape (Situation, Task, Action, Result):

   - **A technical problem you solved:** the spoofed username in `logslayer` ([Module 3](../03-python/07-never-trust-input.md)), or the RDP hole Checkov found ([Module 8](../08-security-concepts/14-scanning-infrastructure-code.md))
   - **A mistake you made and fixed:** locking yourself out of SSH ([Module 2](../02-linux/09-ssh.md)), or anything from your [stuck log](../00-start-here/05-getting-unstuck.md)
   - **A time you checked AI's work:** a real entry from your [AI check log](../01-ai-foundations/01-what-ai-is.md) where Claude was wrong and you caught it

   Write each in `career/stories.md`, about 90 seconds spoken.

## Break it

Give the pitch with no proof. Remove part 3 and say it out loud: "I learned AWS, IAM, and AI security." Now imagine you're the interviewer who's heard that sentence 30 times this month. What do you remember?

Then add the proof back: "I built a notes app in AWS and then ran a simulated breach against it: a leaked key, detected by an alarm I wrote, contained in minutes, with a postmortem." That's the one the interviewer remembers, and asks about. **Specifics are what make you memorable.** Every claim in your pitch should be one you can follow with "for example."

## With Claude

Ask Claude Code to interview you:

```text
Ask me "tell me about yourself" for a [your target role] interview. After I
answer, ask one follow-up question about something I said, the way a real
interviewer would. Then tell me what was strong, what was vague, and what
an interviewer would probably remember.
```

**Answer out loud first, then type it.** **Check the work:** is Claude's feedback specific to what you said, or generic ("great energy!")? If it's generic, ask it to quote the vaguest sentence you said. That's the line to fix.

## Check yourself

1. What are the four parts of the 60-second pitch?
   <details><summary>Answer</summary>

   Where you're from, what you did, proof (a specific project and result), and why this role.
   </details>

2. What's the STAR shape for a story?
   <details><summary>Answer</summary>

   Situation, Task, Action, Result.
   </details>

3. Why include a mistake story?
   <details><summary>Answer</summary>

   Interviewers ask about failures to see honesty and how you learn. A specific mistake you caught and fixed is more convincing than a claim that you don't make them.
   </details>

## Go deeper

- The [mock interviews](../appendix/mock-interviews.md): every "what a good answer sounds like" uses a specific, real example. Notice the pattern.
