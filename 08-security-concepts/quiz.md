# Module 8 quiz

Answer each question out loud or on paper *before* you open the answer.

1. Name the three letters of the CIA triad, and one notes-app control for each.
   <details><summary>Answer</summary>

   Confidentiality (private buckets, least-privilege roles), Integrity (signed delete requests, S3 versioning), Availability (API throttling, rebuilding from code).
   </details>

2. Why is a passkey phishing-resistant when an authenticator app code isn't?
   <details><summary>Answer</summary>

   The passkey checks the real website's address before it signs anything, so it won't work on a fake site. A code can be typed into a fake site and relayed to the real one.
   </details>

3. A role's policy allows something the code never calls. How do you find that, and what do you do?
   <details><summary>Answer</summary>

   Compare the policy with the code line by line, and check IAM's last-accessed data. Remove it, then test that the app, its logs, and its background jobs still work.
   </details>

4. A request arrives with valid credentials from inside your own AWS account. Under zero trust, is it allowed?
   <details><summary>Answer</summary>

   Only if that identity's permissions allow that specific action. Where it comes from doesn't matter; authenticated isn't the same as authorized.
   </details>

5. How does a security group allow traffic from "the app tier," without listing IP addresses?
   <details><summary>Answer</summary>

   By referencing the app tier's security group ID as the source. Anything in that group can connect, wherever it is.
   </details>

6. What's the difference between an AWS-owned, AWS-managed, and customer-managed KMS key?
   <details><summary>Answer</summary>

   AWS-owned: free, invisible to you. AWS-managed: free, in your account, use visible in CloudTrail. Customer-managed: about $1/month, and you control its key policy, rotation, and disabling.
   </details>

7. How does Session Manager let you into a server with no inbound ports open?
   <details><summary>Answer</summary>

   The SSM agent on the server connects outbound to AWS, and AWS relays your session to it. Access is controlled by IAM (`ssm:StartSession`) and logged in CloudTrail.
   </details>

8. A CVSS 9.8 with 0.1% EPSS, or a CVSS 7.5 on CISA's KEV list. Which do you fix first?
   <details><summary>Answer</summary>

   The KEV one: it's being exploited now.
   </details>

9. Give one STRIDE threat for the notes app's public `POST /notes` route.
   <details><summary>Answer</summary>

   Any of: Denial of service (flooding it), Repudiation (no identity on who posted), Tampering with an AI's instructions (a stored prompt injection in a note).
   </details>

10. Your managed-settings policy denies `Bash(sudo *)` and the file is owned by root. Can Claude Code change the policy?
    <details><summary>Answer</summary>

    No. Changing it needs `sudo`, which the policy itself denies, and managed settings can't be overridden from user or project settings. Only a human admin can change it.
    </details>

11. How does your pipeline deploy to AWS without a stored key?
    <details><summary>Answer</summary>

    OIDC: GitHub issues a short-lived token per run, and AWS exchanges it for temporary credentials for a role whose trust policy only accepts that repository's production environment, which needs a human approval.
    </details>

12. Checkov reports 50 findings. What do you do?
    <details><summary>Answer</summary>

    Triage each: fix the real ones, and accept the rest only with a written reason (cost, design, later, or false positive) in a reviewed config file. Never skip just to make the scanner quiet.
    </details>

## Challenge

Play [flaws.cloud](http://flaws.cloud/). It's free and built to be attacked, so it's on your [allowed list](../00-start-here/02-ethics-and-the-law.md). For each level, write which lesson in this module would have prevented the mistake, and which Checkov check (if any) would have flagged it before deployment.
