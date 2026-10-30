# Dig Deeper: Elastic (SIEM)

**Pillars:** ☁️ Cloud · 🪪 Identity · 🤖 AI

> **Optional track, for SOC analysts.** Do [Module 9](../../09-incident-response/) first: this track rebuilds its detections in a real SIEM.

## Why this matters

Almost every SOC analyst posting asks for SIEM experience. A SIEM is where a SOC lives: every log in one place, searchable in seconds, with detection rules that raise alerts. You've built each piece by hand in this course. Here you use the real thing: Elasticsearch, Kibana, and Elastic Security, free to run yourself on the Basic license.

## Opinions

- **Elastic**, run locally in Docker with Elastic's own [`start-local`](https://github.com/elastic/start-local) script, pinned to a version, inside your VM. Bound to localhost, reached through an SSH tunnel.
- **Your own data:** the `auth.log` and CloudTrail samples from Modules 3 and 6, then your VM's live SSH log.
- **Splunk** is the other SIEM you'll see on postings. Splunk Free exists, but it's proprietary and capped at 500 MB a day. The skills transfer: questions, fields, time ranges, and rules are the same everywhere.

> **Memory:** Elasticsearch and Kibana need about 3 GB beyond Ubuntu. Give your VM 6 GB or more, which usually means a 16 GB laptop. Lesson 1 has a low-memory setting that works, slowly.

## Ready to put it on your resume when…

- [ ] You can run Elastic locally without exposing it to the network
- [ ] You can bring in logs with the correct time field, and explain why it matters
- [ ] You can search with KQL, and count, group, and extract fields with ES|QL
- [ ] You can build a dashboard that answers specific questions in 30 seconds
- [ ] You can write threshold, single-event, and new-terms detection rules, map them to ATT&CK, and tune them with narrow exceptions
- [ ] You can ship live logs with a least-privilege API key
- [ ] You can review an AI-written detection rule for fields and logic that would silently never fire

Then list it [honestly](../../10-capstone-and-hired/07-listing-dig-deeper-honestly.md): "hands-on lab experience with Elastic Security: ingestion, ES|QL, dashboards, and detection rules for SSH and CloudTrail."

## Lessons

1. [Run Elastic](01-run-elastic.md): `start-local`, localhost binding, and an SSH tunnel to Kibana
2. [Getting logs in](02-getting-logs-in.md): uploading `auth.log` and CloudTrail, and why the time field matters
3. [Searching](03-searching.md): KQL and ES|QL, including the spoofed username, again
4. [Dashboards](04-dashboards.md): a "SOC morning check" that passes the 30-second test
5. [Detection rules](05-detection-rules.md): threshold and single-event rules, ATT&CK mapping, triage, and tuning
6. [Live logs from your VM](06-live-logs.md): a least-privilege shipper and a live alert

## Practice

- [Quiz](quiz.md)
- [Project: the incident, in a SIEM](project.md)

## When you're done

```bash
cd ~/elastic/elastic-start-local && sudo ./uninstall.sh
```

This deletes all Elastic data. Export your dashboards and rules first (lessons 4 and 5).

## Go deeper

- [Elastic's detection rules repository](https://github.com/elastic/detection-rules)
- [Sigma](https://sigmahq.io/): detection rules in a vendor-neutral format
