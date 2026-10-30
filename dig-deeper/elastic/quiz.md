# Elastic quiz

Answer each question out loud or on paper *before* you open the answer.

1. You publish Elasticsearch's port with `-p 9200:9200` in a VM with `ufw` on. Who can reach it?
   <details><summary>Answer</summary>

   Anyone who can reach the VM. Docker's published ports go around `ufw`. Bind to `127.0.0.1` instead.
   </details>

2. You uploaded logs, but Discover shows nothing. What are the first two things you check?
   <details><summary>Answer</summary>

   The time range, and whether the right field was chosen as the time field.
   </details>

3. Write an ES|QL query that counts denied CloudTrail calls per identity.
   <details><summary>Answer</summary>

   `FROM cloudtrail-lab | WHERE errorCode IS NOT NULL | STATS denied = COUNT(*) BY userIdentity.arn | SORT denied DESC`
   </details>

4. Your GROK pattern counts a failed login from `10.0.0.1` that never happened. What's wrong?
   <details><summary>Answer</summary>

   The pattern matched the first `from <ip> port` in a line where the attacker put a fake one in their username. Anchor the pattern to the end of the line, which sshd writes.
   </details>

5. What makes a dashboard panel worth keeping?
   <details><summary>Answer</summary>

   It answers a specific question, and the answer leads to an action.
   </details>

6. When is a single-event rule better than a threshold rule?
   <details><summary>Answer</summary>

   When the event should never happen at all, like a pipeline identity creating an IAM user. One is enough to alert, with almost no false positives.
   </details>

7. Your rule alerts every time Claude's view-only role explores the account. How do you fix it?
   <details><summary>Answer</summary>

   A narrow exception for exactly that identity from your known IP. Never a broad exception for the role, or a higher threshold for everyone.
   </details>

8. A rule has been enabled for a month and has never alerted. Is that good news?
   <details><summary>Answer</summary>

   Not necessarily. Test it against data where it should fire. A wrong or misspelled field name makes a rule silently match nothing.
   </details>

9. Why give a log shipper its own API key?
   <details><summary>Answer</summary>

   So a compromised server can only add logs to one index, not read other logs or delete evidence of its own compromise.
   </details>

## Challenge

Pick three rules from [Elastic's detection rules repository](https://github.com/elastic/detection-rules) for AWS CloudTrail. For each, explain what it detects, which ATT&CK technique it maps to, and what fields it needs that your raw upload doesn't have (because real deployments map CloudTrail to ECS). Then write your own version of one that works on `cloudtrail-lab`.
