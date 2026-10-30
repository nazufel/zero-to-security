# Live logs from your VM

**Pillars:** ☁️ Cloud · 🤖 AI

## Why this matters

Uploading files is fine for practice and for investigations. A real SIEM **collects** continuously: every server ships its logs as they're written, so a rule can alert on an attack minutes after it starts. In this lesson, your VM's own SSH log flows into Elastic live, and a rule watches it.

## Do it

1. **Make an API key just for shipping logs.** A log shipper should be able to **write** to one index and nothing else, not log in as the `elastic` superuser. In Kibana, open **Dev Tools** and run:

   ```text
   POST /_security/api_key
   {
     "name": "vm-auth-shipper",
     "role_descriptors": {
       "write_authlog": {
         "index": [
           { "names": ["authlog-live"], "privileges": ["create_doc", "create_index"] }
         ]
       }
     }
   }
   ```

   It returns an `encoded` value. That's a credential: treat it like one ([Module 8](../../08-security-concepts/06-secrets-management.md)). Least privilege, again: if this key leaks, it can add log lines to one index. It can't read anything, or delete anything.

2. **Ship new lines as they arrive.** For a lab, a tiny shipper is enough, and you can read every line of it. Save as `~/elastic/ship-auth.sh`:

   ```bash
   #!/usr/bin/env bash
   # ship-auth.sh: send each new SSH journal line to Elasticsearch as it's written.
   # Lab only. Real deployments use Elastic Agent or Filebeat.
   set -euo pipefail
   : "${ES_API_KEY:?set ES_API_KEY to the encoded API key}"

   journalctl -u ssh -f -o json --since now | while read -r line; do
     echo "$line" | jq -c '{
       "@timestamp": (.__REALTIME_TIMESTAMP | tonumber / 1000000 | floor | todateiso8601),
       "host": ._HOSTNAME,
       "message": .MESSAGE
     }' | curl -s -o /dev/null -w "%{http_code}\n" \
          -H "Authorization: ApiKey $ES_API_KEY" -H "Content-Type: application/json" \
          -X POST "http://localhost:9200/authlog-live/_doc" --data-binary @-
   done
   ```

   It follows the SSH journal ([Module 2](../../02-linux/08-logs-and-pipes.md)), turns each entry into a small JSON document with the event's own timestamp ([lesson 2](02-getting-logs-in.md)), and posts it. Run it:

   ```bash
   chmod 755 ~/elastic/ship-auth.sh
   read -rs ES_API_KEY && export ES_API_KEY
   sudo -E ~/elastic/ship-auth.sh
   ```

   (`read -rs` takes the key without echoing it or saving it in your shell history.) Leave it running.

3. **Attack yourself.** From your laptop, fail a few SSH logins as a user that doesn't exist, like [Module 2, lesson 8](../../02-linux/08-logs-and-pipes.md). In the shipper's window, each line prints `201`: stored. In Discover, create a data view for `authlog-live` and watch them arrive.

4. **Detect it live.** Create a threshold rule on `authlog-live`: query `message : "Invalid user"`, threshold `>= 3`, grouped by nothing (or by `host`), running every minute. Fail a few more logins. Within a couple of minutes: an alert, on your own VM, from your own attack.

5. Stop the shipper with `Ctrl+C`. Commit `ship-auth.sh` (never the key).

## Break it

Try to misuse the shipper's key. With `ES_API_KEY` still set:

```bash
curl -s -H "Authorization: ApiKey $ES_API_KEY" "http://localhost:9200/cloudtrail-lab/_search?size=1"
curl -s -H "Authorization: ApiKey $ES_API_KEY" -X DELETE "http://localhost:9200/authlog-live"
```

Both are refused (`security_exception ... unauthorized`). A compromised server holding that key can't read your CloudTrail, or delete the evidence of its own compromise. Now imagine you'd used the `elastic` password in the shipper, as many tutorials do: an attacker on any shipping server could read every log in the SIEM and delete the ones about themselves. **The SIEM's own credentials are a target. Give each source only what it needs.**

`unset ES_API_KEY` when you're done.

## With Claude

Ask Claude Code:

```text
Read ~/elastic/ship-auth.sh. What happens if Elasticsearch is down for 10
minutes? What happens to a log line containing attacker-controlled text?
Compare it to what Elastic Agent or Filebeat does. Don't run anything.
```

**Check the work:** honest answers: when Elasticsearch is down, `curl` fails and those lines are **lost**, because the script has no buffer or retry (real shippers queue and retry). Attacker text goes into `message` safely, because `jq` builds the JSON, so a username with quotes or braces can't break the document. (If the script built JSON by pasting strings together, it could.) Check both claims by reading the script yourself. Does Claude suggest real Elastic Agent or Filebeat features? Check them in [Elastic's docs](https://www.elastic.co/docs/reference/fleet).

## Check yourself

1. Why give a log shipper its own API key instead of the `elastic` password?
   <details><summary>Answer</summary>

   Least privilege. If the server is compromised, the key can only add documents to one index. It can't read other logs or delete evidence.
   </details>

2. Why use the event's own timestamp, not the time it was shipped?
   <details><summary>Answer</summary>

   Shipping can be delayed. The event time is when it actually happened, which is what timelines and rules need.
   </details>

3. What's the biggest weakness of the lab shipper?
   <details><summary>Answer</summary>

   No buffering or retries: if Elasticsearch is unreachable, log lines are lost. Real shippers queue and retry.
   </details>

## Go deeper

- [Elastic Agent and Fleet](https://www.elastic.co/docs/reference/fleet): how real deployments collect logs from many hosts.
