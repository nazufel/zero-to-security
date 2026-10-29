# Ethics and the law

## Why this matters

The tools you'll learn in this course are the same tools attackers use. The only difference between a security engineer and a criminal is **permission**. People have lost job offers, and some have been charged with crimes, for "just scanning" a system they didn't own.

This lesson is short. The rule isn't.

## The rule

> **Only scan, test, or poke at things you own, or that you have written permission to test.**

That's it. "It was public," "I didn't break anything," and "I was just curious" are not permission.

Most countries have laws against unauthorized computer access. In the US it's the Computer Fraud and Abuse Act (CFAA); in the UK it's the Computer Misuse Act. You don't need to memorize them. You need to follow the rule.

## Where you *can* practice

| Target | Why it's okay |
|---|---|
| Your own VM (Module 2 onward) | You own it |
| Your own AWS account and resources | You own them. AWS publishes [what you may test](https://aws.amazon.com/security/penetration-testing/) |
| [scanme.nmap.org](http://scanme.nmap.org/) | The Nmap project explicitly allows light scanning of this one host |
| [OverTheWire](https://overthewire.org/wargames/), [flaws.cloud](http://flaws.cloud/), and other labs in this course | Built to be attacked, by people who invite you to |

Notice what's *not* on the list: your employer's network, your school's Wi-Fi, a friend's website, or a coffee shop. Even if someone says "go ahead" out loud, get it in writing first.

## Do it

1. Create a file called `rules-of-engagement.md`.
2. Write, in your own words, three to five rules you'll follow while learning. Start with this:

   ```markdown
   # My rules of engagement

   1. I only scan and test systems I own or have written permission to test.
   2.
   3.
   ```

3. Add at least one rule about **data**: what will you do if you accidentally see someone else's private information?

This goes in your portfolio in [lesson 3](03-git-and-github.md). Interviewers notice it.

## Break it

Read this scenario and decide what's wrong:

> Sam is learning network scanning. Sam runs a scan against the company network at their retail job "to practice", finds an open database, and reports it to their manager, proud of the find.

<details><summary>What's wrong</summary>

Good intentions, no permission. Sam could be fired or worse, even though they reported it. The right move was to ask the IT or security team for written permission *before* scanning anything, or to practice on a lab instead.
</details>

## With Claude

Ask Claude:

```text
I'm learning security. Give me three realistic situations where a beginner
might accidentally cross the line into unauthorized testing.
```

**Check the work:** for each situation Claude gives, write down the one question the person should have asked before they started. If Claude's examples feel far-fetched, ask it for more realistic ones.

## Check yourself

1. Your friend says, "Sure, try to hack my website." Are you covered?
   <details><summary>Answer</summary>

   Not really. Get it in writing, and make sure they actually own the site and the server it runs on. Many sites run on hosting they don't control, and the hosting company didn't give you permission.
   </details>

2. You find a company's database open on the internet without trying. What should you do?
   <details><summary>Answer</summary>

   Don't download or explore the data. Look for the company's vulnerability disclosure policy (often at `/.well-known/security.txt` on their site) and report it through that channel.
   </details>

## Go deeper

- [disclose.io](https://disclose.io/): what responsible disclosure looks like, and safe-harbor policies that protect good-faith researchers.
