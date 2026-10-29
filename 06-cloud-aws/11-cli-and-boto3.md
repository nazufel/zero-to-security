# The AWS CLI, `boto3`, and CloudTrail

**Pillars:** ☁️ Cloud · 🪪 Identity · 🤖 AI

## Why this matters

Every click in the console, every `aws` command, every `boto3` call, and every OpenTofu apply is an **API call** to AWS. **CloudTrail** records them: who made the call, what it was, when, from which IP address, and whether it was allowed. When something goes wrong in an AWS account, CloudTrail is the first place a SOC analyst looks. It's `/var/log/auth.log` for the whole cloud.

In this lesson you'll read your own account's trail from the CLI and from Python, and teach `logslayer` to read it.

## Do it

1. **Event history** is on in every account, free, for the last 90 days of management events. Look at yours from the CLI:

   ```bash
   aws cloudtrail lookup-events --max-results 5 --query 'Events[].[EventTime,EventName,Username]' --output table
   ```

   You'll see your own recent work: `CreateFunction`, `CreateTable`, `PutParameter`, and so on. `--query` filters the JSON down to the parts you want, and `--output table` makes it readable. (Events can take a few minutes to appear.)

2. Look at one full event:

   ```bash
   aws cloudtrail lookup-events --max-results 1 --query 'Events[0].CloudTrailEvent' --output text | jq .
   ```

   The parts that matter for an investigation:

   | Field | What it tells you |
   |---|---|
   | `userIdentity.arn` | **Who**: a user, or a role and the session using it |
   | `eventName`, `eventSource` | **What**: the API call, and which service |
   | `eventTime` | **When**, in UTC |
   | `sourceIPAddress` | **From where**: an IP, or a service like `lambda.amazonaws.com` |
   | `userAgent` | **With what**: the CLI, a browser, `boto3`, or a script |
   | `errorCode` | Whether it was **denied**, like `AccessDenied` |

3. **Read a trail with Python, by hand.** This course includes a sample export from a made-up account having a bad night. Download it:

   ```bash
   mkdir -p ~/my-security-portfolio/cloud && cd ~/my-security-portfolio/cloud
   curl -fsSLO https://raw.githubusercontent.com/nazufel/zero-to-security/main/06-cloud-aws/samples/cloudtrail-events.json
   ```

   Create `ct_summary.py`:

   ```python
   # ct_summary.py: who did what, from where, in a CloudTrail export
   import json
   import sys

   with open(sys.argv[1]) as f:
       events = json.load(f)["Events"]

   summary = {}
   for event in events:
       detail = json.loads(event["CloudTrailEvent"])
       who = detail["userIdentity"].get("arn", "unknown")
       where = detail.get("sourceIPAddress", "unknown")
       key = (who, where)
       if key not in summary:
           summary[key] = {"calls": 0, "denied": 0}
       summary[key]["calls"] += 1
       if detail.get("errorCode") in ("AccessDenied", "AccessDeniedException", "UnauthorizedOperation"):
           summary[key]["denied"] += 1

   for (who, where), counts in sorted(summary.items(), key=lambda item: item[1]["denied"], reverse=True):
       print(f"{counts['calls']:>4} calls  {counts['denied']:>3} denied  {where:<22} {who}")
   ```

   Two new Python ideas: `CloudTrailEvent` is JSON **inside** a JSON string, so it needs its own `json.loads`; and a **tuple**, `(who, where)`, can be a dictionary key, so you count per person **and** per IP at once.

   ```bash
   python3 ct_summary.py cloudtrail-events.json
   ```

   ```
      8 calls    5 denied  203.0.113.99           arn:aws:iam::123456789012:user/ci-deploy
      5 calls    0 denied  198.51.100.77          arn:aws:iam::123456789012:user/admin
      1 calls    0 denied  198.51.100.77          arn:aws:sts::123456789012:assumed-role/claude-readonly/claude-code
   ```

   The top line should make you sit up. A user called `ci-deploy`, a pipeline account, made 8 calls from an IP nobody recognizes, using `python-requests`, and was denied 5 times. Look at its calls:

   ```bash
   jq -r '.Events[] | select(.Username == "ci-deploy") | "\(.EventTime) \(.EventName)"' cloudtrail-events.json | sort
   ```

   `GetCallerIdentity` ("who am I?"), then trying `ListUsers`, `GetSecretValue`, `CreateUser`... That's what someone does with a **stolen access key**: find out what it can do. Two calls succeeded, `ListBuckets` and `GetParameter`. You'll investigate exactly this in Module 9. For now, notice how quickly 14 events became a story.

4. **Now with `boto3`**, against your own account. Create `fetch_events.py`:

   ```python
   # fetch_events.py: save recent CloudTrail events to a JSON file
   import json
   import sys

   import boto3

   client = boto3.client("cloudtrail")
   events = []
   for page in client.get_paginator("lookup_events").paginate(PaginationConfig={"MaxItems": 200}):
       events.extend(page["Events"])

   with open(sys.argv[1], "w") as f:
       json.dump({"Events": events}, f, indent=2, default=str)
   print(f"Saved {len(events)} events to {sys.argv[1]}")
   ```

   A **paginator** handles AWS returning results in pages. `boto3` uses the same credentials as the CLI (your `lab` profile). Run it with `uv`, which pulls in `boto3` just for this run, without installing it anywhere ([Module 3](../03-python/09-packages.md)):

   ```bash
   uv run --with boto3 fetch_events.py my-events.json
   python3 ct_summary.py my-events.json
   ```

   Your own account's story: you, OpenTofu working as you, and AWS services acting on your behalf.

5. Commit the scripts, **not** your own account's events (they include your IP and account details):

   ```bash
   echo "my-events.json" >> .gitignore
   git add .gitignore ct_summary.py fetch_events.py
   git commit -m "Add CloudTrail summary and fetch scripts"
   git push
   ```

## Break it

Find out what the trail **doesn't** show. Read every note in your table, the way a thief with the right access would:

```bash
aws dynamodb scan --table-name notes-notes --query 'Count'
```

Wait five minutes, then look for it:

```bash
aws cloudtrail lookup-events --lookup-attributes AttributeKey=EventName,AttributeValue=Scan --max-results 5
```

```json
{
    "Events": []
}
```

Nothing. Now look for something you **changed** today, like your Lambda code:

```bash
aws cloudtrail lookup-events --lookup-attributes AttributeKey=EventSource,AttributeValue=lambda.amazonaws.com \
  --max-results 5 --query 'Events[].[EventTime,EventName]' --output table
```

There it is. Event history records **management events**: creating, changing, describing, and listing things. It does **not** record **data events**, like reading an item from DynamoDB or an object from S3. Those are off by default, because there are so many of them. A thief who reads every note in your table can leave no trace in event history at all.

That's the gap attackers count on, and the kind of thing a SOC analyst has to know before saying "the logs show nothing happened." You'll turn on more logging in Module 9.

## With Claude

Now teach `logslayer` to read CloudTrail, with Claude, the way you worked in [Module 3, lesson 12](../03-python/12-building-with-claude-code.md). Copy the sample into the project:

```bash
cp ~/my-security-portfolio/cloud/cloudtrail-events.json ~/my-security-portfolio/logslayer/samples/
cd ~/my-security-portfolio/logslayer
claude
```

Switch to Plan mode:

```text
Add a --cloudtrail flag to logslayer. When it's set, the log file is a
CloudTrail export from `aws cloudtrail lookup-events --output json`, and the
report shows each identity ARN and source IP with its number of calls and
number of denied calls, most denied first. Keep the existing auth.log mode
working. Add tests using samples/cloudtrail-events.json. Standard library only.
```

**Check the work** with your `CLAUDE.md` rules and these:

- [ ] `uv run logslayer --cloudtrail samples/cloudtrail-events.json` matches your `ct_summary.py` output
- [ ] `uv run logslayer samples/auth.log` still works exactly as before, and all the old tests pass
- [ ] No `boto3` dependency was added: `logslayer` reads files, it doesn't call AWS
- [ ] A malformed event (delete a `"` from the sample in a copy) is counted as skipped, not a crash ([Module 3, lesson 7](../03-python/07-never-trust-input.md))
- [ ] `--json` output works in CloudTrail mode too, if you built it in Module 3

Commit when every box is checked.

## Check yourself

1. Which CloudTrail fields answer "who, what, when, from where"?
   <details><summary>Answer</summary>

   `userIdentity.arn`, `eventName` (and `eventSource`), `eventTime`, and `sourceIPAddress`.
   </details>

2. An identity calls `GetCallerIdentity`, then gets `AccessDenied` on five different services in a minute. What does that pattern suggest?
   <details><summary>Answer</summary>

   Someone with stolen credentials discovering what they can do. Legitimate automation calls the same few things it was built for.
   </details>

3. Someone read every item in your DynamoDB table. Will CloudTrail event history show it?
   <details><summary>Answer</summary>

   Probably not. Item reads are data events, which aren't recorded by default. You'd need a trail with data events turned on.
   </details>

## Go deeper

- [CloudTrail event history](https://docs.aws.amazon.com/awscloudtrail/latest/userguide/view-cloudtrail-events.html): what's recorded for free, and for how long.
- [Boto3 documentation](https://docs.aws.amazon.com/boto3/latest/): the Python SDK, with every service's calls.
