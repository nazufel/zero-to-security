# Module 9: Incident Response & Forensics

**Pillars:** ☁️ Cloud · 🪪 Identity · 🤖 AI

## Why this module matters

Every security team eventually has a bad day. What separates a scare from a disaster is how fast you notice, how calmly you run it, and how honestly you learn from it afterward. This is the daily work of a SOC analyst, and every engineer gets pulled in eventually.

## You're ready to move on when…

- [ ] You can decide whether something is an incident, and declare one
- [ ] You can run an incident using PagerDuty's framework: roles, severity, communication
- [ ] You can find who did what, from where, in CloudTrail
- [ ] You can set up CloudWatch logs, metrics, and an alarm that pages you
- [ ] You can follow a request through your app with a trace
- [ ] You can tell a true positive from a false positive, and know when to escalate
- [ ] You can describe an attack in MITRE ATT&CK terms
- [ ] You can analyze a phishing email: headers, links, and attachments, safely
- [ ] You can explain the order of volatility and chain of custody, and triage a Linux host
- [ ] You can build an incident timeline and write a blameless postmortem
- [ ] You can say where AI helps in an incident and where a human must make the call

## Lessons

1. [What's an incident?](01-whats-an-incident.md) And how to declare one without fear
2. [Running an incident](02-running-an-incident.md): [PagerDuty's Incident Response framework](https://response.pagerduty.com/): incident commander, scribe, subject matter experts, severity levels, status updates, as a tabletop exercise
3. [Audit logs: CloudTrail](03-audit-logs.md): a trail with data events and tamper detection. Who, what, when, from where. *(OWASP A09: Security Logging and Alerting Failures)*
4. [Monitoring](04-monitoring.md): CloudWatch logs, metrics, and alarms that email you
5. [Network evidence](05-network-evidence.md): VPC Flow Logs
6. [Traces](06-traces.md): a correlation ID and AWS X-Ray, following one request end to end
7. [Querying logs](07-querying-logs.md): Athena over CloudTrail
8. [Alert triage](08-alert-triage.md): true positive, false positive, escalation
9. [MITRE ATT&CK](09-mitre-attack.md): the SOC's shared vocabulary
10. [Phishing analysis](10-phishing-analysis.md): the most common SOC ticket, with a [sample email](samples/phish.eml)
11. [Forensics basics](11-forensics-basics.md): order of volatility, chain of custody, Linux host triage, EBS snapshots
12. [Timelines and postmortems](12-timelines-and-postmortems.md): blameless, specific, with action items
13. [AI in the SOC](13-ai-in-the-soc.md): a log-triage subagent, and a "write-postmortem" skill. Where AI shouldn't make the final call.

## Project: [the incident](project.md)

A scripted "attack" on your own notes app, using [`simulate-attack.sh`](scenario/simulate-attack.sh): a leaked access key is used to read data.

1. **Detect it:** an alarm fires; `logslayer` (now with a detection mode) flags it in CloudTrail
2. **Run it:** declare it, assign roles, and work through it as a tabletop exercise
3. **Contain it:** disable the key, check what it touched
4. **Write it up:** a blameless postmortem with a timeline and action items, in your portfolio

Plus the [quiz](quiz.md), with the SOC mock interview as its challenge.

## Dig Deeper

- SIEM concepts and writing detection rules
- Threat intel basics: indicators of compromise
- Endpoint security and EDR concepts
- Windows event logs for SOC work
- GuardDuty during its free trial
