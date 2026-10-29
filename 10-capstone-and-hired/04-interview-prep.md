# Interview prep

**Pillars:** ☁️ Cloud · 🪪 Identity · 🤖 AI

## Why this matters

Knowing the material and explaining it under pressure are two different skills. Interviews test the second. People who could build everything in this course still freeze when a stranger asks "walk me through what happens when you type a URL," because they've only ever **known** the answer, never **said** it.

The fix is the same as for everything else in this course: practice by doing. Out loud, timed, repeated.

## Do it

1. **Run all three mock interviews.** The [mock interviews](../appendix/mock-interviews.md) have ten questions each, for help desk, SOC analyst, and junior cloud/security engineer. Start with the one for your target role:

   - Read the question. **Answer out loud**, timed: aim for one to two minutes.
   - Then open "what a good answer sounds like" and "why they're asking."
   - Score yourself 1 to 3 per question: 1 = stumbled, 2 = got there, 3 = clear and specific with an example.

   Track it in `career/interview-practice.md`:

   ```markdown
   | Date | Interview | Q | Score | What I missed |
   |---|---|---|---|---|
   ```

2. **Use your own work in every answer you can.** Most questions map to something you built. "What's wrong with this IAM policy?" is your [Module 7](../07-identity/04-policies.md) work. "How do you tell a true positive from a false positive?" is your [Module 9 triage](../09-incident-response/08-alert-triage.md). An answer that starts "When I built..." beats one that starts "Generally, you would...".

3. **Practice the technical whiteboard questions by doing them.** Some interviews ask you to do something live. Practice these with a timer:

   - Subnet a `/24` into four, and say each range ([Module 4](../04-networking/02-subnets-and-cidr.md))
   - Read an IAM policy out loud as sentences, and predict a request's result ([Module 7](../07-identity/05-evaluation-logic.md))
   - Find the failed logins in a log with `grep` and pipes ([Module 2](../02-linux/08-logs-and-pipes.md))
   - Explain what happens when you type a URL, in under two minutes ([Module 4](../04-networking/quiz.md))

4. **Prepare your questions for them.** At the end, you'll be asked "any questions for us?" Have three ready that show you think like the role. For example: "What does your team do when an alert fires at 2 a.m.?" "How does your team use AI tools, and what rules are there around them?" "What does a new person's first month look like?"

5. **Repeat.** Run your target interview again a week later. Compare scores. The goal is 3s on at least eight of ten.

## Break it

Practice not knowing. In a real interview, you will get a question you can't answer. The worst responses are bluffing (interviewers can tell, and then doubt everything else) and freezing.

Pick a question from a mock interview for a role you're **not** targeting, one you genuinely can't answer well. Say out loud: what you do know that's related, how you'd find out the rest, and where you'd look. For example: "I haven't worked with Windows event logs directly. I know the Linux equivalents well, like `auth.log` and `journalctl`, and I'd expect to look for logon events and failed logons the same way. I'd check Microsoft's documentation for the event IDs." That's a strong answer to a question you couldn't answer. It's the [Getting unstuck](../00-start-here/05-getting-unstuck.md) method, out loud.

## With Claude

Run a full mock interview with Claude, using the prompt at the end of the [mock interviews page](../appendix/mock-interviews.md#practice-with-claude). Answer each question **out loud first**, then type what you said.

**Check the work:** after the interview, take the two weakest areas Claude named and check them against this course. Are they real gaps, or did Claude ask about something outside entry-level scope (a specific SIEM product, Kubernetes internals)? Practice the real gaps. For anything outside scope, practice the "what I know, how I'd find out" answer from Break it instead of cramming.

## Check yourself

1. Why practice answers out loud instead of reading them?
   <details><summary>Answer</summary>

   Interviews test explaining under pressure, which is a separate skill from knowing. Saying it is the only way to practice saying it.
   </details>

2. You get a question you can't answer. What do you do?
   <details><summary>Answer</summary>

   Say what you know that's related, how you'd find the rest, and where you'd look. Never bluff.
   </details>

3. Why start answers with your own work?
   <details><summary>Answer</summary>

   A specific example from something you built is more convincing than a general description, and it leads the conversation to your strengths.
   </details>

## Go deeper

- The [mock interviews](../appendix/mock-interviews.md), all three, even the ones for roles you're not targeting. Help desk questions come up in SOC interviews and vice versa.
