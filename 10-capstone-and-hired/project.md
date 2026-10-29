# Project: ready to apply

**Pillars:** ☁️ Cloud · 🪪 Identity · 🤖 AI

## Why this matters

This is the finish line of the course, and the starting line of the job hunt. Everything here is something a hiring manager, a recruiter, or an interviewer will see or ask about. When every box below is checked, you're not "learning security." You're a candidate with proof.

## What to build

```text
my-security-portfolio/
├── README.md              # lesson 1: "Start here" in 60 seconds
├── career/                # private notes can stay out of the public repo (see below)
│   ├── resume-bullets.md  # lesson 2
│   ├── pitch.md           # lesson 3
│   ├── stories.md         # lesson 3
│   ├── interview-practice.md  # lesson 4
│   ├── ai-answer.md       # lesson 5
│   ├── certifications.md  # lesson 6
│   ├── extras.md          # lesson 7
│   └── practice-plan.md   # lesson 8
└── (everything you built in Modules 0–9)
```

> **Public or private?** Your portfolio is public, and that's the point. Your resume, pitch, and interview notes don't need to be. Keep `career/` in a **private** repository, or a private folder that's in `.gitignore`. Your resume has your contact details; the portfolio should have only what you'd put on a business card.

## The checklist

### Portfolio

- [ ] The README's "Start here" table leads with the four projects that best fit your target role
- [ ] A non-technical person can tell what you do in under a minute
- [ ] Every project README answers: what, why, what you did (by hand and with AI), what you learned
- [ ] All three pillars are proven:

  | Pillar | Proof | Your link |
  |---|---|---|
  | ☁️ Cloud | The notes app, defined entirely in OpenTofu, deployed by the pipeline | |
  | 🪪 Identity | Its identity design, least-privilege roles, and an OIDC pipeline with no stored keys | |
  | 🤖 AI | Built with Claude, reviewed by you, governed by your managed-settings policy | |
  | All three | An incident you detected, ran, and wrote up | |

- [ ] No secrets, state files, or personal data anywhere in the history (run gitleaks one last time)
- [ ] Pinned on your GitHub profile

### Resume and pitch

- [ ] One page, plain format, projects above experience
- [ ] Every bullet has a specific result, and you can talk about each for two minutes
- [ ] A tailored version for at least three real postings
- [ ] Your 60-second pitch, said out loud without notes, under 70 seconds
- [ ] Three STAR stories: a technical problem, a mistake, and a time you caught AI being wrong

### Interviews

- [ ] All three [mock interviews](../appendix/mock-interviews.md) answered out loud, with your target role's scoring 3 on at least eight of ten
- [ ] Your answer to "Aren't you worried AI will replace you?", out loud, under 90 seconds
- [ ] Three questions to ask them
- [ ] A full mock interview with Claude, answered out loud

### Next steps

- [ ] A certification decision, with the data behind it
- [ ] At least one Dig Deeper topic or lab, described honestly
- [ ] A weekly practice plan you've kept for two weeks
- [ ] **Your first five applications sent**

## With Claude

Ask Claude Code to be the hiring panel:

```text
You're a hiring panel for a [your target role]: a recruiter, a hiring
manager, and a senior engineer. Each of you reviews my portfolio README and
the project READMEs it links to, for 2 minutes. Each of you tells me one
thing that makes you want to interview me, one concern, and one question
you'd ask me. Don't rewrite anything.
```

**Check the work:** answer each question out loud. For each concern, decide if it's real; if it is, fix it or prepare an answer. Check any claim the "panel" makes about what's in your repo; it should match the files.

## Done when

Every box is checked, and you've hit send on five applications. Then keep your [practice plan](08-keep-practicing.md) going, update the "What I'm working on now" line on your portfolio, and keep applying.

Good luck. You've earned the interview.
