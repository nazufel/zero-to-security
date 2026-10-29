# Zero trust

**Pillars:** 🪪 Identity · ☁️ Cloud

## Why this matters

The old model was a castle: a strong wall (the firewall), and everyone inside trusted. Then laptops left the office, apps moved to the cloud, and attackers learned that once they got inside the wall, by phishing one employee, nobody checked them again. **Zero trust** drops the wall-as-trust idea: **never trust a request because of where it comes from; verify every request, every time**, based on who's making it.

Your notes app has a weak spot that's exactly this problem. The delete route trusts anyone who has the admin token, a shared secret. Whoever has it is "the admin," with no name attached, and no way to know who deleted what.

## Do it

You'll replace the token with **identity**: the delete route will only accept requests signed with real AWS credentials, from a principal allowed to delete. Every delete will then be tied to a name.

1. **Require a signature on delete.** In `notes-app/infra/api.tf`, replace the route resource with:

   ```hcl
   locals {
     # Route => who may call it. AWS_IAM means: a signed request from an identity allowed to invoke it.
     routes = {
       "GET /notes"         = "NONE"
       "POST /notes"        = "NONE"
       "DELETE /notes/{id}" = "AWS_IAM"
     }
   }

   resource "aws_apigatewayv2_route" "notes" {
     for_each = local.routes

     api_id             = aws_apigatewayv2_api.notes.id
     route_key          = each.key
     authorization_type = each.value
     target             = "integrations/${aws_apigatewayv2_integration.notes.id}"
   }
   ```

   Now API Gateway checks the request's AWS signature, and the signer's IAM permissions (`execute-api:Invoke`), **before** the function runs.

2. **Check the caller in the code too.** In `lambda/notes.py`, replace `delete_note`:

   ```python
   def delete_note(event):
       # API Gateway only lets signed (AWS_IAM) requests reach this route. Check anyway:
       # if the route is ever misconfigured, fail closed instead of open.
       caller = event.get("requestContext", {}).get("authorizer", {}).get("iam", {}).get("userArn")
       if not caller:
           return respond(403, {"error": "forbidden"})
       note_id = event["pathParameters"]["id"]
       table.delete_item(Key={"id": note_id})
       print(json.dumps({"deleted": note_id, "by": caller}))
       return respond(200, {"deleted": note_id})
   ```

   Two layers again (API Gateway and the code), and the code **fails closed** ([Module 3](../03-python/06-errors.md)). And every delete now logs **who** did it.

   Delete the now-unused `admin_token()` function, the `ssm` client, and `import hmac`.

3. **Remove the shared secret's permissions.** In `lambda.tf`, remove the `ssm:GetParameter` statement and the `TOKEN_PARAM` environment variable. In `variables.tf`, remove `admin_token_param`. Then apply.

4. **Delete a note, as you.** `curl` can sign requests with AWS credentials. Export your temporary credentials into the shell, then sign:

   ```bash
   tofu apply
   API=$(tofu output -raw api_url)
   ID=$(curl -s -X POST "$API/notes" -d '{"text": "delete me with identity"}' | jq -r .id)

   eval "$(aws configure export-credentials --format env)"
   curl -s -X DELETE "$API/notes/$ID" \
     --aws-sigv4 "aws:amz:us-east-1:execute-api" \
     --user "$AWS_ACCESS_KEY_ID:$AWS_SECRET_ACCESS_KEY" \
     -H "x-amz-security-token: $AWS_SESSION_TOKEN"
   unset AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN
   ```

   ```json
   {"deleted": "..."}
   ```

   Check who did it:

   ```bash
   aws logs tail /aws/lambda/notes-api --since 5m | grep deleted
   ```

   ```
   {"deleted": "...", "by": "arn:aws:sts::123456789012:assumed-role/..."}
   ```

   Not "someone with the token." A name.

5. **Delete the old secret.** Nothing uses it now:

   ```bash
   aws ssm delete-parameter --name /notes/admin-token
   ```

   The best secret is one you don't need.

6. Commit:

   ```bash
   git add api.tf lambda.tf variables.tf ../lambda/notes.py
   git commit -m "Zero trust: deletes require a signed request, not a shared token"
   git push
   ```

## Break it

Try to delete three ways, and see each one verified:

```bash
ID=$(curl -s -X POST "$API/notes" -d '{"text": "try to delete me"}' | jq -r .id)

# 1. No signature at all
curl -s -X DELETE "$API/notes/$ID"

# 2. The old admin token
curl -s -X DELETE "$API/notes/$ID" -H "x-admin-token: anything"

# 3. A real, valid identity that isn't allowed to delete: Claude's view-only role
eval "$(aws configure export-credentials --profile claude --format env)"
curl -s -X DELETE "$API/notes/$ID" --aws-sigv4 "aws:amz:us-east-1:execute-api" \
  --user "$AWS_ACCESS_KEY_ID:$AWS_SECRET_ACCESS_KEY" -H "x-amz-security-token: $AWS_SESSION_TOKEN"
unset AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN
```

```
{"message":"Forbidden"}
{"message":"Forbidden"}
{"message":"Forbidden"}
```

The third is the important one. That request came with **valid, authenticated** credentials, from inside your own account. In the castle model, being inside would have been enough. Here, the identity was checked against its permissions, and it isn't allowed. That's zero trust: authenticated isn't the same as authorized, and location means nothing.

## With Claude

Ask Claude Code:

```text
Where else in notes-app does something trust a request because of where it
comes from, instead of verifying who sent it? List each place and a fix.
```

**Check the work:** good answers include: `GET` and `POST` are open to anyone (a choice for a public demo, but say so); the queue trusts any message (the poison message from [Module 6](../06-cloud-aws/09-messages.md)); the lab server's security group used to trust an IP address (gone in lesson 7). For each one Claude suggests, decide: real gap, accepted risk, or wrong? Write accepted risks down; deciding not to fix something is fine when it's on purpose.

## Check yourself

1. What does "never trust, always verify" mean in practice?
   <details><summary>Answer</summary>

   Every request is checked for who sent it and whether that identity is allowed, regardless of whether it comes from inside the network or the account.
   </details>

2. Why is an identity better than a shared admin token?
   <details><summary>Answer</summary>

   Each action is tied to a specific principal (so you know who did it), access can be granted and removed per person, and there's no shared secret to leak or rotate.
   </details>

3. A request is signed with valid credentials but still gets `403`. Why?
   <details><summary>Answer</summary>

   Authentication passed, authorization didn't: that identity's policies don't allow the action.
   </details>

## Go deeper

- [NIST SP 800-207: Zero Trust Architecture](https://csrc.nist.gov/pubs/sp/800/207/final): the standard definition, readable in sections.
