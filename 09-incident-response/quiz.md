# Module 9 quiz

Answer each question out loud or on paper *before* you open the answer.

1. You're 60% sure an alert is a real attack. What do you do?
   <details><summary>Answer</summary>

   Declare an incident (or escalate), then downgrade or close it if you're wrong. Declaring a false alarm is cheap; delaying on a real one is expensive.
   </details>

2. Name the four PagerDuty incident roles, and what the incident commander shouldn't do.
   <details><summary>Answer</summary>

   Incident commander, scribe, subject matter experts, and communications liaison. The IC shouldn't investigate or fix things themselves; they coordinate and decide.
   </details>

3. What three things does a CloudTrail trail give you that free event history doesn't?
   <details><summary>Answer</summary>

   Any three of: long-term storage you control, data events (like reading DynamoDB items), every region, tamper detection (log file validation), and streaming to CloudWatch for alarms.
   </details>

4. Describe the chain from a CloudTrail event to an email in your inbox.
   <details><summary>Answer</summary>

   CloudTrail → CloudWatch Logs → a metric filter counts matching events → a metric → an alarm crosses its threshold → SNS topic → confirmed email subscription.
   </details>

5. A flow log record ends in `REJECT` for destination port 3389. What happened?
   <details><summary>Answer</summary>

   Something tried to connect to Remote Desktop on your instance, and a security group or NACL blocked it. Usually internet scanning.
   </details>

6. What's a correlation ID, and why pass it into a queue message?
   <details><summary>Answer</summary>

   An ID logged at every step of one request, so you can follow it across services. Passing it into the message lets you link the worker's logs back to the original request.
   </details>

7. An alarm fires for 6 denied calls, all from `ci-deploy`, all denied. Can you close it because "nothing got through"?
   <details><summary>Answer</summary>

   No. The alert only shows the failures. Check what that identity's **successful** calls were, and contain the credential either way.
   </details>

8. Map these to MITRE ATT&CK tactics: `ListUsers`, `CreateUser`, `GetSecretValue`.
   <details><summary>Answer</summary>

   Discovery, Persistence, and Credential Access.
   </details>

9. A phishing email's From says `billing@microsoft.com`. Name three things to check.
   <details><summary>Answer</summary>

   Any three of: the Return-Path and Reply-To domains, the SPF/DKIM/DMARC results, where the links really go (the `href`), and attachments with double extensions. And: did anyone click or enter a password?
   </details>

10. Put in order: snapshot the disk, collect running processes, reboot the server, swap to an isolation security group.
    <details><summary>Answer</summary>

    Snapshot the disk, collect running processes (most volatile evidence), then isolate with the security group. Don't reboot: it destroys memory evidence.
    </details>

11. What makes a postmortem blameless, and what does every action item need?
    <details><summary>Answer</summary>

    It asks what in the system let the mistake happen, not who made it. Every action item needs a type, an owner, and a date.
    </details>

12. Name two incident decisions AI should never make on its own.
    <details><summary>Answer</summary>

    Any two of: declaring or closing an incident, running containment actions that change systems, deciding what to communicate and to whom, and anything about a person.
    </details>

## Challenge

Answer the SOC analyst [mock interview](../appendix/mock-interviews.md#interview-2-soc-analyst) out loud, all ten questions, using your own incident from the project as the example wherever you can. Record yourself. Your best answer to "tell me about an incident" should now be a true story, told in three minutes: what happened, how you found it, what you did first, what you learned, and what changed.
