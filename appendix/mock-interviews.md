# Mock interviews

Three interviews, one per target role, ten questions each. Every question uses something you built or learned in this course.

**How to use these:**

1. Read the question. **Answer out loud**, as if you're in the room. Time yourself: aim for one to two minutes.
2. Then open **What a good answer sounds like** and **Why they're asking**.
3. Don't memorize the sample answers. Interviewers can tell. Learn the *shape*: what they're listening for.

At the end there's a prompt to have Claude run a mock interview with you.

---

## Interview 1: Help Desk / IT Support

### 1. A user says "the internet is down." Walk me through troubleshooting it.

<details><summary>What a good answer sounds like</summary>

"First I'd ask a couple of questions: is it just them or others too, and what exactly isn't working, one website or everything? If it's just them, I'd work up from the bottom: is the cable plugged in or Wi-Fi connected, do they have an IP address, can they ping the default gateway, then can they reach an IP on the internet, and finally can they resolve a name with DNS. If an IP works but a name doesn't, it's DNS. If it's everyone, it's probably not their laptop, so I'd check for an outage and escalate."
</details>

<details><summary>Why they're asking</summary>

It's the most common ticket there is. They want a **method**, not guesses. Asking scoping questions first and working layer by layer shows you won't waste time, and knowing when it's bigger than one user shows judgment. *(Module 4)*
</details>

### 2. Someone calls asking for a password reset. What do you do first?

<details><summary>What a good answer sounds like</summary>

"Verify who they are before I touch anything, using whatever process the company has: a callback to the number on file, a manager confirmation, or an identity check in the ticketing system. Attackers call help desks pretending to be employees all the time. Once they're verified, I reset it, make them change it at next login, and note it in the ticket."
</details>

<details><summary>Why they're asking</summary>

Social engineering of help desks is a real and common attack path. The wrong answer is "reset it." The right answer starts with **identity verification**. *(Module 7: authentication)*
</details>

### 3. What happens when you type a URL into a browser and press Enter?

<details><summary>What a good answer sounds like</summary>

"The browser looks up the domain's IP address with DNS. It opens a TCP connection to that IP on port 443, does a TLS handshake to set up encryption and check the site's certificate, then sends an HTTP request. The server sends back a response with a status code, like 200 OK, and the page content, and the browser renders it."
</details>

<details><summary>Why they're asking</summary>

It's a classic because it touches everything: DNS, TCP, ports, TLS, HTTP. They're not after every detail, they want to see the **order** is right and you know which piece breaks what. *(Module 4)*
</details>

### 4. A service on a Linux server won't start. Where do you look?

<details><summary>What a good answer sounds like</summary>

"`systemctl status` for the service first. It shows whether it failed and the last few log lines. Then `journalctl -u` with the service name for the full logs. Usually the error is right there: a bad config file, a port already in use, or a permissions problem. I'd also check whether anything changed recently, like an update or a config edit."
</details>

<details><summary>Why they're asking</summary>

They want to hear you go to **the logs** before guessing, and that you know the actual commands. "What changed recently?" is a bonus: most outages follow a change. *(Module 2)*
</details>

### 5. A user can't open a shared file. How do you figure out why?

<details><summary>What a good answer sounds like</summary>

"I'd get the exact error message first. If it says access denied, it's permissions: I'd check what permissions the file has and which groups the user is in. Usually they're missing from a group. I wouldn't just give them direct access, though. I'd check with the file's owner that they should have it, then add them to the right group."
</details>

<details><summary>Why they're asking</summary>

Two things: getting the **exact error**, and not "fixing" access problems by handing out permissions. Adding to a group, after the owner approves, is least privilege in action. *(Modules 2, 7)*
</details>

### 6. Explain MFA to a frustrated, non-technical employee.

<details><summary>What a good answer sounds like</summary>

"I get it, it's an extra step. Think of it like your house: your password is the key, and MFA is the alarm code. If someone steals your key, they still can't get in without the code on your phone. Most of the account takeovers we see happen because someone's password leaked, and MFA stops almost all of them."
</details>

<details><summary>Why they're asking</summary>

Help desk is half people skills. They want **empathy first**, then plain language with no jargon. Can you explain security without making someone feel stupid? *(Module 7)*
</details>

### 7. A user forwards you a suspicious email. What now?

<details><summary>What a good answer sounds like</summary>

"First, thank them for reporting it. I want people to keep doing that. Then I'd ask if they clicked anything or entered a password. If they did, that's urgent: reset their password and escalate to security. Either way, I'd look at the sender's real address and where the links actually go, without clicking them, and pass it to the security team so they can block it and check if anyone else got it."
</details>

<details><summary>Why they're asking</summary>

Phishing reports are daily work. The key question is **"did you click or type anything?"** because that changes the priority. Thanking the reporter shows you understand security depends on people. *(Module 9)*
</details>

### 8. Tell me about a time you didn't know the answer.

<details><summary>What a good answer sounds like</summary>

Use a real entry from your **stuck log**. For example: "Building my VM's hardening script, I locked myself out of SSH. I didn't know why. I read the error, worked out that I'd disabled password login before my key was copied over, and fixed it from the VM console. Now I always test a new SSH session before I close the old one."
</details>

<details><summary>Why they're asking</summary>

Nobody knows everything, and they know it. They want to see **how you get unstuck**: a method, honesty, and a lesson learned. A specific story beats a general claim every time. *(Module 0)*
</details>

### 9. How do you use AI at work, and how do you keep it safe?

<details><summary>What a good answer sounds like</summary>

"I use it like a fast junior teammate: to explain errors, draft scripts, and write first drafts of documentation. I always check its work, because it can be confidently wrong. And I never paste in passwords, customer data, or anything confidential. If the company has an approved AI tool and rules for it, I follow those."
</details>

<details><summary>Why they're asking</summary>

Every company is figuring this out right now. They want someone who uses AI to be **faster**, but **checks the work** and **doesn't leak data**. *(Module 1)*
</details>

### 10. Walk me through a project in your portfolio.

<details><summary>What a good answer sounds like</summary>

Pick one project and use this shape: **what** it is, **why** you built it, **one hard part** and how you solved it, and **what you'd do differently**. For example, your hardened VM: what you locked down, why each step matters, the time you locked yourself out, and what you'd automate next.
</details>

<details><summary>Why they're asking</summary>

This is where your portfolio pays off. They're checking that you **actually did it** and **understand why**. Expect follow-up questions on any line. *(Every module)*
</details>

---

## Interview 2: SOC Analyst

### 1. How do you tell a true positive from a false positive?

<details><summary>What a good answer sounds like</summary>

"I'd start with context: is this behavior normal for this user or system? For example, a login from a new country is suspicious, unless the user is traveling and logged in with MFA from their usual device. I'd look at related logs around the same time, check whether there's a known explanation like a scheduled job or a change ticket, and document what I found either way. If I can't rule it out, I escalate rather than close it."
</details>

<details><summary>Why they're asking</summary>

This is the core of the job. They want to hear **context**, **corroborating evidence**, **documentation**, and a bias toward escalating when unsure. Closing real alerts as false positives is how breaches get missed. *(Module 9)*
</details>

### 2. `auth.log` shows 5,000 failed SSH logins from one IP. What's your next move?

<details><summary>What a good answer sounds like</summary>

"The key question is whether any login *succeeded*. Failed attempts from one IP are usually an automated brute-force attack, which is common on internet-facing SSH. So I'd check for a successful login from that IP or right after the failures. If there's none, I'd block the IP and recommend key-only SSH or closing port 22. If one succeeded, it's an incident: that account is compromised."
</details>

<details><summary>Why they're asking</summary>

Volume isn't the point; **success** is. Plenty of candidates panic at 5,000 failures and miss the one success that matters. This is exactly what you built `logslayer` to find. *(Modules 2, 3, 9)*
</details>

### 3. Walk me through analyzing a phishing email.

<details><summary>What a good answer sounds like</summary>

"I'd look at the headers to see where it really came from, not just the display name, and whether it passed SPF, DKIM, and DMARC. I'd check where links really go by hovering or looking at the raw source, never clicking them. Attachments I'd treat as hostile and only examine in a sandbox. Then I'd check whether anyone else received it, and whether anyone clicked, and block the sender and domain."
</details>

<details><summary>Why they're asking</summary>

It's one of the most common SOC tickets. They want **safe handling** (don't click) and **scoping**: who else got it, and did anyone bite? *(Module 9)*
</details>

### 4. What is MITRE ATT&CK, and how would you use it?

<details><summary>What a good answer sounds like</summary>

"It's a public catalog of the tactics and techniques attackers really use, like credential access or lateral movement, organized by what the attacker is trying to achieve. In a SOC it's a shared vocabulary: I can say an alert looks like a specific technique, and everyone knows what to look for next. It also helps spot gaps: which techniques we have no detections for."
</details>

<details><summary>Why they're asking</summary>

It's on most SOC job postings. You don't need to memorize technique IDs; they want to know you understand it's a **common language** and a way to think about **what comes next** in an attack. *(Module 9)*
</details>

### 5. CloudTrail shows an `AssumeRole` call from an IP you've never seen. Investigate.

<details><summary>What a good answer sounds like</summary>

"First, who called it: which user or role made the request, and which role did they assume? Then, what did that session do afterward? CloudTrail links the assumed-role session back to the original identity. I'd check whether the IP fits a known location, like a VPN or CI system, and whether the original credentials could have leaked. If I can't explain it, I'd treat it as compromised and escalate."
</details>

<details><summary>Why they're asking</summary>

This is cloud identity investigation, and few juniors can do it. They want to see you **trace the chain**, from original identity to assumed role to actions, which is impersonation and audit logs together. *(Modules 7, 9)*
</details>

### 6. When do you declare an incident, and what happens next?

<details><summary>What a good answer sounds like</summary>

"When there's real or likely impact, or I'm not sure, I declare. It's better to declare and stand down than to wait. Then I follow the process: assign an incident commander, set a severity, open a channel or bridge, and start a timeline. The commander coordinates, others investigate, and someone keeps notes and sends regular updates."
</details>

<details><summary>Why they're asking</summary>

Juniors often hesitate to "make a fuss." They want someone who **declares early** and knows that incidents need **roles and structure**, not everyone typing at once. *(Module 9)*
</details>

### 7. What's the order of volatility, and why does it matter?

<details><summary>What a good answer sounds like</summary>

"It's the order in which evidence disappears. Memory and running processes go first, then network connections, then files on disk, then backups and logs stored elsewhere. It matters because if you reboot or shut down a compromised machine first, you lose everything in memory. So you collect the most volatile evidence first, or snapshot the system before touching it."
</details>

<details><summary>Why they're asking</summary>

It checks whether you'd **destroy evidence by accident**. "Just reboot it" is the classic mistake. In the cloud, the answer includes snapshotting the disk before making changes. *(Module 9)*
</details>

### 8. What are ports 22, 53, and 443, and what's the difference between TCP and UDP?

<details><summary>What a good answer sounds like</summary>

"22 is SSH, 53 is DNS, 443 is HTTPS. TCP sets up a connection and guarantees delivery in order, which is why it's used for web traffic and SSH. UDP just sends packets with no guarantee, which is faster, so it's used for things like DNS lookups and video calls."
</details>

<details><summary>Why they're asking</summary>

Basic fluency. You'll read these numbers in every alert and log. Quick, confident answers here buy you credibility for the harder questions. *(Module 4)*
</details>

### 9. Where should AI *not* make the call in a SOC?

<details><summary>What a good answer sounds like</summary>

"AI is great for summarizing logs, drafting timelines, and suggesting what to check next. But a human should make the decisions with real consequences: declaring or closing an incident, disabling a production system, or anything involving a person, like deciding an employee did something wrong. AI can be confidently wrong, and it can be tricked by attacker-controlled data in the logs, which is prompt injection."
</details>

<details><summary>Why they're asking</summary>

SOC teams are adopting AI fast. They want someone who knows its **value and its limits**. Bringing up **prompt injection through log data** is a standout answer. *(Modules 1, 8, 9)*
</details>

### 10. What makes a good postmortem?

<details><summary>What a good answer sounds like</summary>

"It's blameless: it focuses on what in the system let the mistake happen, not who made it, so people stay honest. It has a clear timeline, the impact, the root cause, and action items with owners and dates. I wrote one for a simulated incident in my portfolio. The most useful part was the action items, because that's what stops it happening again."
</details>

<details><summary>Why they're asking</summary>

They want **blameless culture** and **action items**, not a story with no follow-through. Pointing to the postmortem you actually wrote is a strong move. *(Module 9)*
</details>

---

## Interview 3: Junior Cloud / Security Engineer

### 1. Map a front end, back end, database, and secrets to AWS services.

<details><summary>What a good answer sounds like</summary>

"For the app I built: the front end is a static site in S3 behind CloudFront. The back end is API Gateway in front of Lambda functions in Python. Data is in DynamoDB. Secrets are in SSM Parameter Store as SecureStrings, and the Lambda reads them at runtime through its role, so nothing's hard-coded. It's all defined in OpenTofu."
</details>

<details><summary>Why they're asking</summary>

It shows you can turn an **architecture into services**, the core skill of cloud work. Mentioning how secrets are accessed (through the role) shows security thinking built in. *(Module 6)*
</details>

### 2. What's wrong with this IAM policy?

```json
{
  "Effect": "Allow",
  "Action": "s3:*",
  "Resource": "*"
}
```

<details><summary>What a good answer sounds like</summary>

"It allows every S3 action on every bucket in the account, including deleting buckets and changing bucket policies to make them public. That breaks least privilege. I'd narrow it to the specific actions needed, like `s3:GetObject` and `s3:PutObject`, on the specific bucket ARN. Then I'd check it with Access Analyzer or the Policy Simulator."
</details>

<details><summary>Why they're asking</summary>

Over-broad policies are among the most common real findings. They want you to spot **both** wildcards, explain the **real risk**, and fix it **specifically**. *(Module 7)*
</details>

### 3. IAM user vs. IAM role: when do you use each?

<details><summary>What a good answer sounds like</summary>

"A user has long-lived credentials tied to one identity. A role has no permanent credentials. You assume it and get temporary ones. Workloads like Lambda, EC2, and CI/CD should always use roles. For humans, at work it's usually single sign-on that hands out roles. The key point is avoiding long-lived access keys, because they leak."
</details>

<details><summary>Why they're asking</summary>

It's foundational, and the follow-up is often "why are access keys bad?" They're listening for **temporary credentials** and **no long-lived keys**. *(Module 7)*
</details>

### 4. An allow and a deny both match a request. What happens, and why?

<details><summary>What a good answer sounds like</summary>

"The deny wins. In AWS, an explicit deny always overrides any allow. And if nothing allows a request, it's denied by default. That's the implicit deny. It's designed that way so you can put guardrails in place that nobody can accidentally override with a broad allow."
</details>

<details><summary>Why they're asking</summary>

Policy evaluation logic is what lets you **predict** access instead of guessing. The "why" part, guardrails, shows you understand the design. *(Module 7)*
</details>

### 5. What is `AssumeRole`, and what's the confused deputy problem?

<details><summary>What a good answer sounds like</summary>

"`AssumeRole` lets a principal temporarily take on a role's permissions, if the role's trust policy allows it. The confused deputy problem is when a trusted service is tricked into using its access on someone else's behalf. For example, a third-party vendor who can assume roles in many customers' accounts gets tricked into acting on yours. The fix is an External ID condition in the trust policy, so the vendor must prove which customer it's acting for."
</details>

<details><summary>Why they're asking</summary>

This is a step above most junior candidates. Getting the **trust policy** part right, and having any grasp of the confused deputy, signals you really understand impersonation. *(Module 7)*
</details>

### 6. You find an AWS access key committed to a public GitHub repo. What do you do?

<details><summary>What a good answer sounds like</summary>

"I treat it as compromised immediately, because bots scan GitHub for keys within minutes. First I deactivate the key so it's useless. Then I check CloudTrail for anything it did, to see if it was used and what the blast radius is. If it was used, I declare an incident. After that I remove it from the repo's history, since deleting the file doesn't remove it from past commits. Finally, I fix the root cause: use roles or OIDC so there's no long-lived key to leak, and turn on secret scanning."
</details>

<details><summary>Why they're asking</summary>

It tests **priority order**. The strongest candidates contain first and investigate second. Saying "delete the commit" first is a red flag: the key still works and is still in git history. Ending with prevention shows you think beyond the immediate ticket. *(Modules 0, 7, 9)*
</details>

### 7. Security groups vs. NACLs. And how do you segment a network?

<details><summary>What a good answer sounds like</summary>

"Security groups attach to resources and are stateful: allow a request in and the response is allowed out automatically. NACLs apply to a whole subnet and are stateless, so you need rules both ways. To segment, I'd put public-facing pieces in public subnets and everything else, like databases, in private subnets, then use security groups so each tier only accepts traffic from the tier in front of it."
</details>

<details><summary>Why they're asking</summary>

It's the cloud version of firewalls and segmentation. **Stateful vs. stateless** is the technical detail; **tiers that only talk to their neighbor** is the design thinking. *(Modules 4, 6, 8)*
</details>

### 8. How do you deploy from CI/CD without storing AWS keys?

<details><summary>What a good answer sounds like</summary>

"With OIDC. GitHub Actions can get a short-lived identity token, and in AWS you set up a role whose trust policy only accepts tokens from your specific repo and branch. The pipeline assumes that role and gets temporary credentials for that run. There's no key stored anywhere to leak. I built exactly this for my portfolio project."
</details>

<details><summary>Why they're asking</summary>

Stored CI keys are a top breach path. Knowing OIDC, and that the **trust policy is scoped to a repo and branch**, puts you ahead of most junior candidates. *(Modules 7, 8)*
</details>

### 9. Why use a minimal container image, and why pin by digest?

<details><summary>What a good answer sounds like</summary>

"A minimal image, like Chainguard's, has only what the app needs: no shell, no package manager, far fewer packages. That means fewer vulnerabilities, and an attacker who gets in has almost no tools. When I scanned a standard Python image against the Chainguard one, the difference in CVE counts was huge. Pinning by digest matters because tags can be moved to point at a different image. A digest can't. The Trivy compromise in 2026 is the example: attackers repointed tags to malicious code."
</details>

<details><summary>Why they're asking</summary>

Supply chain security is a hot topic (it's A03 on the OWASP Top 10:2025). Quoting **your own scan results** and a **real incident** is far stronger than reciting best practices. *(Module 5)*
</details>

### 10. An AI agent needs access to your AWS account. How do you set that up safely?

<details><summary>What a good answer sounds like</summary>

"I treat it like a new junior engineer. Don't put AI into your world; give it the parts it needs, explicitly. It gets its own role, never my credentials, with only the permissions for the task, ideally read-only to start. I'd limit where it can reach on the network, run it in a sandbox like a VM or container, and use managed settings and hooks to block risky commands. Everything it does shows up in CloudTrail under its own identity, so I can audit it. That's how you limit the blast radius if it's wrong or gets prompt-injected."
</details>

<details><summary>Why they're asking</summary>

This is the newest question on the list and it's showing up more and more. It brings all three pillars together: **cloud**, **identity**, and **AI**. A clear, structured answer here is memorable. *(Modules 1, 7, 8)*
</details>

---

## Practice with Claude

Paste this into Claude to run a mock interview:

```text
You're interviewing me for an entry-level [help desk / SOC analyst / junior
cloud security engineer] role. Ask me one question at a time from the topics
below, and wait for my answer before continuing. After each answer, tell me
what was strong, what was missing, and what an interviewer would ask next.
Don't give me the model answer unless I ask. After 10 questions, give me an
overall score and the two things I should practice most.

Topics: Linux, networking, AWS, IAM, containers, incident response, phishing,
using AI safely, and my portfolio projects.
```

**Answer out loud first, then type your answer.** The point is practicing speaking, not writing.
