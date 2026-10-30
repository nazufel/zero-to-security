# Project: the incident, in a SIEM

**Pillars:** ☁️ Cloud · 🪪 Identity · 🤖 AI

## Why this matters

In [Module 9's project](../../09-incident-response/project.md), you detected a leaked key with a CloudWatch alarm and `logslayer`. Now do it the way a SOC would: in a SIEM, with rules, a dashboard, and an alert workflow. "I rebuilt my detections in Elastic and compared them with my own tool" is a strong SOC interview story.

## What to build

In `~/my-security-portfolio/elastic/`:

- `rules/`: your exported detection rules, at least four, each with ATT&CK mapping and an investigation guide
- `dashboard.ndjson` and a screenshot: the "SOC morning check"
- `queries.md`: the ES|QL searches you used to investigate
- `README.md`: the comparison below

## Steps

1. **Bring in the incident.** Use your Module 9 project's CloudTrail export (`incident-events.json`), or rerun [`simulate-attack.sh`](../../09-incident-response/scenario/simulate-attack.sh) for fresh events. Convert it to NDJSON as in [lesson 2](02-getting-logs-in.md) (without the timestamp shift if it's recent), and upload it as `cloudtrail-incident`.
2. **Point your rules at it** (add the index pattern), and wait for the alerts.
3. **Investigate from the alert:** timeline, every action by the key, what succeeded. Save each search in `queries.md`.
4. **Compare your three detectors** in the README:

   | Detector | Fired? | Time to alert | What it saw | What it missed |
   |---|---|---|---|---|
   | CloudWatch alarm (Module 9) | | | | |
   | `logslayer --detect` (Module 9) | | | | |
   | Elastic rules | | | | |

5. **Add one detection you didn't have before**, with a new-terms or single-event rule, for something the incident did that none of the three caught. Test that it fires.
6. Commit.

## With Claude

Give Claude Code your exported rules and ask it to find ways an attacker could avoid each one (going slower than the threshold, using a different region, using services you don't watch). For each realistic evasion, decide: a new rule, a tuned rule, or an accepted gap. Write them in the README.

## Done when

- [ ] At least four rules, exported, each with ATT&CK mapping and an investigation guide, and each tested against data where it should fire
- [ ] The dashboard passes the 30-second test on the incident data
- [ ] The comparison table is filled in honestly, misses included
- [ ] You can walk an interviewer from the alert to the impact in three minutes
