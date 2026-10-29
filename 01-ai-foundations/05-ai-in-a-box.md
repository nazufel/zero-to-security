# AI in a box

**Pillars:** 🤖 AI · 🪪 Identity · ☁️ Cloud

## Why this matters

A chatbot can only talk. An **agent** can act: run commands, edit files, call cloud APIs. In July 2025, an AI coding agent on Replit deleted a company's live production database during a code freeze, despite being told not to change anything. The AI wasn't malicious. It had access it didn't need, and nothing stopped it from using it.

An agent running with your login can do anything you can do. This lesson is the course's answer to that.

## The stance

> **Don't put AI into your world. Give AI parts of your world, explicitly.**
>
> Treat AI like a very hard-working, very fast junior engineer. Same rules as any new hire: least privilege, access controls, network controls, segmentation. Limit the blast radius, and wherever you can, put it in a box.

**Blast radius** is how much damage a mistake can do. You can't make AI perfect. You can make its mistakes small.

## Do it

1. Create `ai-foundations/ai-box-plan.md`. Fill in the **junior engineer** column first, as if you were their manager on day one. Then fill in the **AI agent** column using the same thinking.

   ```markdown
   # AI box plan

   | Question | New junior engineer, day one | AI agent |
   |---|---|---|
   | Whose account do they use? |  |  |
   | What files and systems can they reach? |  |  |
   | What network can they reach? |  |  |
   | Where do they do risky work? |  |  |
   | What can they do without asking? |  |  |
   | How do you see what they did? |  |  |
   ```

   <details><summary>One good answer</summary>

   | Question | New junior engineer | AI agent |
   |---|---|---|
   | Whose account? | Their own, never a shared admin login | Its own identity, never your keys |
   | What can they reach? | Only the systems for their first project | Only the project folder it's working in |
   | What network? | The office network, not production | Only the sites it needs, nothing internal |
   | Where's risky work? | A test environment | A VM or container you can throw away |
   | Without asking? | Read docs, run tests | Read and edit project files. Anything else, it asks. |
   | How do you see it? | Tickets, commit history, audit logs | Commit history, command logs, audit logs under its own name |
   </details>

2. Add the boxes you'll build in this course to the same file:

   ```markdown
   ## The boxes I'll build

   | Box layer | What it limits | Module |
   |---|---|---|
   | VM sandbox | AI can only touch the VM, not my laptop | 2 |
   | Containers | AI-written code runs with almost nothing around it | 5 |
   | Network controls | Where AI can connect to, and where data can go | 4, 6 |
   | Its own IAM role | What AI can do in AWS, under its own name | 7 |
   | Hooks and managed settings | Commands AI is blocked from running | 8 |
   | Audit logs | Proof of what AI did, and when | 9 |
   ```

3. Now measure a blast radius. Picture an agent running directly on your laptop, logged in as you. List everything it could reach. Start with these, then add your own:

   - Your browser's saved passwords and logged-in sessions
   - Your email
   - Your SSH keys and any cloud credentials in your home folder
   - Push access to your GitHub repos

   Then picture the same agent inside a VM that only holds one project folder. What's left on the list?

## Break it

Walk through this failure:

> You ask an agent to "clean up the old test files." It misreads which folder you meant and runs `rm -rf` on the wrong one.

For each box layer in your table, write one line: would it have **prevented** this, **limited** it, **let you recover**, or **let you find out**? (Hint: a VM with a snapshot doesn't stop the mistake, but it lets you undo it in a minute.)

No single layer stops everything. That's the point of having several. Security people call it **defense in depth**, and you'll build it one module at a time.

## With Claude

Ask Claude to describe its own box:

```text
Imagine you're an AI agent on my computer. Your only job is helping me write
Python in one project folder. List the minimum access you'd need, and what
you should NOT have.
```

**Check the work:** compare its list against your AI agent column. Did it ask for anything you'd say no to, like `sudo`, your whole home folder, or unrestricted internet? AI, like people, often asks for what's convenient instead of what's needed. Least privilege is your job, not its.

```bash
git add ai-foundations/ai-box-plan.md
git commit -m "Add AI box plan"
git push
```

## Check yourself

1. What's the difference between a chatbot and an agent?
   <details><summary>Answer</summary>

   A chatbot only produces text. An agent can take actions, like running commands or editing files, so its mistakes have real effects.
   </details>

2. Why give an AI agent its own identity instead of letting it use yours?
   <details><summary>Answer</summary>

   So you can limit its access to just what the task needs, and so audit logs show what the AI did versus what you did.
   </details>

3. A VM snapshot doesn't stop an agent from deleting files. Why is it still a box layer?
   <details><summary>Answer</summary>

   It limits the blast radius to the VM and lets you recover fast. Not every control has to prevent; some contain, recover, or detect.
   </details>

## Go deeper

- [OWASP: Excessive Agency](https://genai.owasp.org/llmrisk/llm062025-excessive-agency/): OWASP's name for giving AI more power than it needs, with real examples and mitigations.
