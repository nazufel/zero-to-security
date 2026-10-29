# Project: your AI usage policy

## Why this matters

Every company is writing rules for how employees use AI, and most of them are figuring it out as they go. An interviewer who asks "how do you use AI safely?" hears a lot of vague answers. You'll be able to point to a policy you wrote and follow. That's rare, and it shows judgment, which is what they're really asking about.

## What to build

By the end of this project, your portfolio has:

```text
my-security-portfolio/
├── README.md
├── ai-usage-policy.md          # this project
├── ai-foundations/
│   ├── ai-check-log.md         # from lesson 1
│   ├── model-choices.md        # from lesson 2
│   ├── prompt-template.md      # from lesson 3
│   ├── redaction-practice.md   # from lesson 4
│   ├── ai-box-plan.md          # from lesson 5
│   ├── owasp-llm-notes.md      # from lesson 6
│   └── claude-ecosystem.md     # from lesson 7
└── ... (your Module 0 files)
```

## Steps

1. **Write `ai-usage-policy.md`** at the root of your repo. Use this structure, and fill it in **in your own words**, pulling from your lesson files:

   ```markdown
   # My AI usage policy

   ## What I use AI for
   (Three to five real uses. "Explaining error messages" counts.)

   ## Which model, when
   (Your decision rule from lesson 2, in one or two sentences.)

   ## What never goes in
   (Your list from lesson 4, plus the check you run before every paste.)

   ## How I check its work
   (What you verify, and against what. Your check log is evidence.)

   ## How I box it in
   (Where AI runs, what it can reach, what it can't do without asking.
   Mark which parts you've built and which are coming in later modules.)

   ## Prompt injection
   (What it is, and the one rule you follow because of it.)

   ## If something goes wrong
   (What you do if you paste a secret, or AI does something you didn't approve.)
   ```

2. **Keep it honest.** Only write rules you actually follow. "I run AI inside a VM" isn't true yet; put it under "coming in Module 2."

3. **Add it to your portfolio README.** Add rows to the "What's here" table:

   ```markdown
   | [AI usage policy](ai-usage-policy.md) | How I use AI and keep it from becoming a security hole |
   | [AI foundations notes](ai-foundations/) | Model choice, prompting, redaction, and the OWASP LLM Top 10 |
   ```

   And update your "What I'm working on now" line to Module 2.

4. **Commit and push.**

   ```bash
   git add ai-usage-policy.md README.md
   git commit -m "Add AI usage policy"
   git push
   ```

## With Claude

Paste your policy into Claude and ask:

```text
You're a security manager reviewing a junior engineer's personal AI usage
policy. What's missing or unclear? Don't rewrite it. Give me three suggestions.
```

**Check the work:** take only the suggestions you'd actually follow. If Claude suggests a rule you'll never stick to, leave it out. A short policy you follow beats a long one you don't. And if it suggests claiming controls you haven't built yet, put them under "coming in later modules" instead.

## Done when

- [ ] `ai-usage-policy.md` is in your public repo, in your own words
- [ ] Every rule in it is one you actually follow today, or is marked as coming later
- [ ] All seven lesson files are in `ai-foundations/`
- [ ] You can explain any line of your policy out loud, without reading it

You'll revisit this policy in Module 8, when you turn your personal rules into a managed-settings policy that enforces them.
