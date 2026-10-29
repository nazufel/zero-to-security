# Listing Dig Deeper work honestly

## Why this matters

Job postings are full of tools you haven't used deeply: Kubernetes, a specific SIEM, Terraform Cloud, Splunk. The temptation is to list them anyway. Interviewers expect this, and they test it: one question about a skill you've overclaimed, and they start doubting everything else on your resume.

The [Dig Deeper](../dig-deeper/) topics let you add real, hands-on experience in those areas. This lesson is about describing it so it helps you instead of hurting you.

## Do it

1. **Use the honest wording pattern:** what you did, with what, at what scale.

   | Overclaim | Honest, and still strong |
   |---|---|
   | Kubernetes expert | Hands-on lab experience with Kubernetes (kind): deployed my own containerized tool, wrote RBAC roles and network policies, and reviewed AI-written manifests for privilege escalation |
   | Experienced with SIEM | Built detection rules for CloudTrail and SSH logs (CloudWatch metric filters and a Python detection tool); familiar with SIEM concepts |
   | Proficient in Splunk | (Leave it off, unless you've used it. Mention the concepts instead.) |
   | Penetration tester | Practiced offensive techniques in legal labs: OverTheWire, flaws.cloud, OWASP Juice Shop |

   The honest version is **longer and more specific**, which is why it's more convincing.

2. **Inventory your extras.** List every Dig Deeper topic you've done, and every lab or challenge (OverTheWire Bandit, flaws.cloud, flaws2.cloud, Juice Shop). For each, write one honest line in `career/extras.md` in the pattern above, and link to evidence: a repo folder, notes, or a writeup.

3. **Prepare the "how deep?" answer.** For each extra, prepare a 30-second answer to "How much have you used it?" Start with what you did, then name a limit honestly: "I've run Kubernetes locally with kind and written RBAC and network policies for my own app. I haven't operated a production cluster. I'd expect the concepts to transfer and the operational side to be new."

4. Pick **one** Dig Deeper topic that matches your target postings and do it, if you haven't yet. One real extra beats five listed ones.

## Break it

Have someone grill you on an overclaim. Ask a friend, or Claude, to interview you on "Kubernetes expert" as if it were on your resume:

```text
My resume says "Kubernetes expert." Ask me three increasingly specific
questions about it, the way a skeptical interviewer would.
```

Answer them. Notice how fast it falls apart, and how it feels. Then have it ask the same three questions about the honest line from step 1. The honest version survives, because every question leads somewhere you've actually been.

## With Claude

Paste your `extras.md` into Claude Code:

```text
Review these resume lines for overclaiming. For each, tell me what an
interviewer would likely ask, and whether the line promises more than the
evidence shows. Suggest more specific wording, without inflating anything.
```

**Check the work:** watch for suggestions that **add** inflation while claiming to be specific ("deployed production-grade Kubernetes workloads"). Your evidence is a lab; say so. "Lab" isn't a weakness on an entry-level resume. It's exactly what they expect, and it's true.

## Check yourself

1. What's the honest wording pattern?
   <details><summary>Answer</summary>

   What you did, with what tool, at what scale, for example "hands-on lab experience with X: did A, B, and C."
   </details>

2. An interviewer asks how deep your Kubernetes experience is. What's a good answer?
   <details><summary>Answer</summary>

   What you did specifically, then an honest limit (like "local labs, not production"), and how you'd expect it to transfer.
   </details>

3. Why is one real extra better than five listed ones?
   <details><summary>Answer</summary>

   You can talk about it in depth, with evidence. Listed skills you can't discuss make interviewers doubt the rest of your resume.
   </details>

## Go deeper

- [Dig Deeper](../dig-deeper/): pick the topic that appears most in your target postings.
