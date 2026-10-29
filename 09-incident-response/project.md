# Project: the incident

**Pillars:** ☁️ Cloud · 🪪 Identity · 🤖 AI

## Why this matters

You'll run a real incident, start to finish, in your own account: a leaked access key, used by an "attacker" to explore and steal data. You'll detect it with the alarms you built, run it with the roles from lesson 2, contain it, measure exactly what was touched, and write it up. "Tell me about an incident you handled" is a question in every SOC interview. After this, you have a true answer, with a postmortem to show.

## Before you start

- The notes app is deployed, with the logging from lessons 3 and 4 (trail with data events, alarms, **confirmed** email subscription).
- There are a few notes in the table.
- Your Athena table from lesson 7 works.
- Read [`simulate-attack.sh`](scenario/simulate-attack.sh) top to bottom. It runs against **your** account only. You should be able to say what every line does before you run it.

## Part 1: the attack

```bash
cd ~ && curl -fsSLO https://raw.githubusercontent.com/nazufel/zero-to-security/main/09-incident-response/scenario/simulate-attack.sh
less simulate-attack.sh
chmod 755 simulate-attack.sh
./simulate-attack.sh setup
sleep 20
./simulate-attack.sh attack
```

`setup` recreates the mistake from [Module 7](../07-identity/02-principals.md): a pipeline IAM user, `ci-deploy`, with a long-lived key, "leaked" into a local profile. `attack` uses that key the way a stranger who found it would. Note the time you ran it. Then put the script away, and work only from the evidence, as if you'd never seen it.

## Part 2: detect it

1. **Wait for the alarm email.** Write down when it arrives. Detection time = email time − attack time.

2. **Teach `logslayer` to detect it.** This is the detection mode promised since Module 3. Build it with Claude Code, the way you worked in [Module 3, lesson 12](../03-python/12-building-with-claude-code.md), Plan mode first:

   ```text
   Add a --detect flag to logslayer. With --cloudtrail, report an alert for:
   1. any identity with 5 or more denied calls within 10 minutes;
   2. any identity that calls GetCallerIdentity and then, within 10 minutes,
      calls 3 or more different AWS services;
   3. any long-lived access key (ID starting with AKIA) used from a source IP
      that identity hasn't used earlier in the file.
   With an auth.log, report an alert for any IP with failed passwords followed
   by a successful login. Each alert names the rule, the identity or IP, the
   time window, and the evidence count. Exit with code 1 if there are any
   alerts. Add tests for every rule, including a case that must NOT alert.
   Standard library only.
   ```

   Review every change against your `CLAUDE.md` and the checklist from the [Module 3 project](../03-python/project.md). Then test it on known data before trusting it on the incident:

   ```bash
   cd ~/my-security-portfolio/logslayer
   uv run logslayer --detect samples/auth.log                      # should flag 203.0.113.7 (and 10.0.2.2)
   uv run logslayer --cloudtrail --detect samples/cloudtrail-events.json   # should flag ci-deploy
   ```

3. **Run it on the incident.** Export the last hour of your trail and run detection:

   ```bash
   cd ~/my-security-portfolio/cloud
   uv run --with boto3 fetch_events.py incident-events.json
   cd ../logslayer && uv run logslayer --cloudtrail --detect ../cloud/incident-events.json
   ```

   Which rules fired? Did any rule **miss** something you can see in the evidence? (A miss is a false negative: note it for the postmortem.)

## Part 3: run it

4. **Declare.** Fill in `incidents/YYYY-MM-DD-ci-deploy.md` from the [lesson 1 template](01-whats-an-incident.md). Severity? Facts only. Start the timeline.

5. **Contain first.** Deactivate the key. **Deactivate, don't delete**: a deactivated key stops working instantly and stays as evidence. Deleting the user would also delete its policy, which is evidence of what the attacker **could** do ([lesson 2](02-running-an-incident.md)).

   ```bash
   aws iam list-access-keys --user-name ci-deploy
   aws iam update-access-key --user-name ci-deploy --access-key-id AKIA... --status Inactive
   aws iam get-user-policy --user-name ci-deploy --policy-name legacy-deploy > ~/my-security-portfolio/incidents/ci-deploy-policy.json
   ```

   Log each action with its time. Prove it's contained: `aws sts get-caller-identity --profile attacker` now fails.

## Part 4: investigate

6. **What did it touch?** Use your [Athena queries](07-querying-logs.md) with the key ID:

   ```sql
   SELECT eventtime, eventsource, eventname, errorcode, sourceipaddress
   FROM cloudtrail_logs_notes_trail_xxxxxxxx
   WHERE useridentity.accesskeyid = 'AKIA...'
   ORDER BY eventtime;
   ```

   Separate the denied calls (intent) from the successful ones (impact). Was a **data event** recorded? Lesson 3's trail records `Scan` on the notes table. If it's there, you can say exactly when every note was read, and from where. Without lesson 3, you couldn't.

7. **What else could it reach?** Read the saved `ci-deploy-policy.json`. The key could list buckets, describe SSM parameters, and scan one table. Did the attacker use all of it? Could they have done more with it than they did?

8. **Map it.** Add the attack's steps to ATT&CK ([lesson 9](09-mitre-attack.md)) in the incident file.

9. **Recover and close.** Now delete the user and clean up the profile (`./simulate-attack.sh cleanup`), and decide: does anything need rotating? (Think about what was exposed: bucket names, parameter names, every note.) Close the incident with a final status update.

## Part 5: write it up

10. **Write the postmortem** with your template from [lesson 12](12-timelines-and-postmortems.md). Then have your `/write-postmortem` skill ([lesson 13](13-ai-in-the-soc.md)) draft one from the same evidence, and compare. Keep yours as the final version, improved by anything the draft caught. Include:

    - The full timeline: attack, alarm, declaration, containment, each investigation step
    - **Detection time** and **containment time**, measured
    - Impact: exactly which notes were read, when, and from where (from the data event)
    - Root cause by five whys, ending in something in the system
    - Your `logslayer` detection results, including anything it missed
    - Action items with type, owner, and date

11. **Commit everything** (but not `incident-events.json`, which contains your account's details):

    ```bash
    cd ~/my-security-portfolio
    echo "cloud/incident-events.json" >> .gitignore
    git add .gitignore incidents/ logslayer/ .claude/
    git commit -m "Incident: leaked ci-deploy key, detected, contained, written up"
    git push
    ```

## With Claude

Ask Claude Code to review your postmortem as the incident's skeptical reader:

```text
Read incidents/*ci-deploy-postmortem.md and check every timeline entry and
impact claim against incidents/ and the evidence I cite. Then: if you were
the attacker, what would you have done differently to avoid each of my
detections? Don't change files.
```

**Check the work:** every evasion idea it gives is a possible new action item. Is it realistic? (Going slower to stay under the alarm's threshold is; "use a zero-day in CloudTrail" isn't.) Add the realistic ones. And verify its fact-check against the evidence yourself: an AI checking an AI-assisted document is still not a human checking it.

## Done when

- [ ] The alarm fired, and you measured detection time
- [ ] `logslayer --detect` flags the incident, has tests for every rule, and you've noted what it missed
- [ ] The key was contained by deactivation, with the policy saved as evidence, before anything was deleted
- [ ] You can say exactly what the attacker read, when, and from where, using the data event
- [ ] The postmortem is blameless, with a timeline, measured times, five whys, and real action items
- [ ] `ci-deploy` is deleted and the `attacker` profile is gone
- [ ] You can tell the story of this incident out loud in three minutes
