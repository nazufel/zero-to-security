# Secrets: Parameter Store

**Pillars:** ☁️ Cloud · 🪪 Identity

## Why this matters

Every year, security researchers scan public GitHub for secrets, and every year they find millions: API keys, database passwords, cloud credentials, most of them in code someone pushed "just for now." Bots do the same scan within minutes of a push. A secret in code is in Git history forever ([Module 0](../00-start-here/03-git-and-github.md)), in every copy of the repo, and in every deployment package.

The fix is a **secret store**: the secret lives in one protected place, and code fetches it at runtime, using its role. In this lesson you'll add a secret to the notes app the wrong way, then rip it out.

## Do it

The notes app needs a delete route, and only you should be able to use it. You'll protect it with an **admin token**: a long random string that has to be sent with every delete.

1. **The wrong way first, so you can see it.** In `notes.py`, add this (don't commit it):

   ```python
   ADMIN_TOKEN = "letmein-12345"


   def delete_note(event):
       if event.get("headers", {}).get("x-admin-token") != ADMIN_TOKEN:
           return respond(403, {"error": "forbidden"})
       table.delete_item(Key={"id": event["pathParameters"]["id"]})
       return respond(200, {"deleted": event["pathParameters"]["id"]})
   ```

   Now list everywhere that token would end up: your Git history, GitHub, the zip file in `infra/build/`, the Lambda console (anyone who can view the function can download its code), and every copy of the repo. Changing it means a code change and a redeploy. **Delete those lines.**

2. **Create the secret outside your code and outside OpenTofu.** Generate a long random token and store it in **Parameter Store** as a **SecureString**, encrypted with AWS KMS:

   ```bash
   aws ssm put-parameter \
     --name /notes/admin-token \
     --type SecureString \
     --value "$(openssl rand -hex 32)"
   ```

   Why not in OpenTofu? You saw it in [lesson 3](03-opentofu-basics.md): anything OpenTofu creates with a value lands in the state file, in plain text. Your `.tf` files only ever refer to the secret's **name**.

   Read it back when you need it:

   ```bash
   aws ssm get-parameter --name /notes/admin-token --with-decryption --query Parameter.Value --output text
   ```

3. **Give the function permission to read that one parameter.** Add a variable to `variables.tf`:

   ```hcl
   variable "admin_token_param" {
     description = "Name of the SSM parameter holding the admin token. Created by hand, never by OpenTofu."
     type        = string
     default     = "/notes/admin-token"
   }
   ```

   In `lambda.tf`, add a statement to the role's policy:

   ```hcl
         {
           Effect   = "Allow"
           Action   = "ssm:GetParameter"
           Resource = "arn:aws:ssm:${var.region}:${data.aws_caller_identity.current.account_id}:parameter${var.admin_token_param}"
         },
   ```

   And add the parameter's **name** (never its value) to the function's environment:

   ```hcl
         TOKEN_PARAM = var.admin_token_param
   ```

   One action, on one parameter. The function can't read any other secret in your account.

4. **Fetch it at runtime.** In `notes.py`, add `import hmac` at the top, then:

   ```python
   ssm = boto3.client("ssm")

   _admin_token = None


   def admin_token():
       """Read the admin token from Parameter Store once, then reuse it."""
       global _admin_token
       if _admin_token is None:
           response = ssm.get_parameter(Name=os.environ["TOKEN_PARAM"], WithDecryption=True)
           _admin_token = response["Parameter"]["Value"]
       return _admin_token


   def delete_note(event):
       given = event.get("headers", {}).get("x-admin-token", "")
       if not hmac.compare_digest(given, admin_token()):
           return respond(403, {"error": "forbidden"})
       table.delete_item(Key={"id": event["pathParameters"]["id"]})
       return respond(200, {"deleted": event["pathParameters"]["id"]})
   ```

   And route it in `handler`:

   ```python
       if route == "DELETE /notes/{id}":
           return delete_note(event)
   ```

   - The token is fetched once per Lambda instance and reused, so you're not calling Parameter Store on every request.
   - `hmac.compare_digest` compares the two strings in constant time. A plain `!=` can stop at the first wrong character, which leaks, very slightly, how much of a guess was right. It's a small detail, and a habit worth having anywhere secrets are compared.

5. Add `"DELETE /notes/{id}"` to the route list in `api.tf`, then apply and test:

   ```bash
   tofu apply
   ID=$(curl -s -X POST "$API/notes" -d '{"text": "delete me"}' | jq -r .id)
   curl -s -X DELETE "$API/notes/$ID"
   curl -s -X DELETE "$API/notes/$ID" -H "x-admin-token: wrong"
   TOKEN=$(aws ssm get-parameter --name /notes/admin-token --with-decryption --query Parameter.Value --output text)
   curl -s -X DELETE "$API/notes/$ID" -H "x-admin-token: $TOKEN"
   ```

   ```
   {"error": "forbidden"}
   {"error": "forbidden"}
   {"deleted": "..."}
   ```

6. Search your repo to prove no secret is in it, then commit:

   ```bash
   cd ~/my-security-portfolio
   git grep -n "letmein" ; git grep -n "$TOKEN"
   cd notes-app/infra
   git add variables.tf lambda.tf api.tf ../lambda/notes.py
   git commit -m "Protect delete with an admin token from Parameter Store"
   git push
   ```

   Both `git grep`s print nothing.

> **Rotating the secret** is now one command, with no code change: `aws ssm put-parameter --name /notes/admin-token --type SecureString --overwrite --value "$(openssl rand -hex 32)"`. New Lambda instances pick it up. **Secrets Manager** is AWS's other secret store; it adds automatic rotation for things like database passwords, for a monthly fee per secret. This course doesn't need it, but you'll see it at work.

## Break it

The "middle way" people often try: put the secret in the function's **environment variables** instead of the code. In `lambda.tf`, add to the function's environment, temporarily:

```hcl
      ADMIN_TOKEN = "letmein-12345"
```

Apply, then look at what anyone with read access to the function sees:

```bash
aws lambda get-function-configuration --function-name notes-api --query Environment.Variables
grep -c letmein terraform.tfstate
```

```json
{
    "TABLE_NAME": "notes-notes",
    "TOKEN_PARAM": "/notes/admin-token",
    "ADMIN_TOKEN": "letmein-12345"
}
```

In plain text in the function's configuration, in the console, in your state file, and in your `.tf` file in Git. Environment variables are for **configuration** (table names, parameter names), not secrets. Remove that line and apply.

## With Claude

Ask Claude Code:

```text
Search this whole repository for anything that looks like a secret: tokens,
passwords, keys, connection strings. Report what you find and where. Don't
change anything.
```

**Check the work:** Claude is fast at this, and also misses things and flags things that aren't secrets. Check each finding yourself. Then run a real secret scanner to compare. [gitleaks](https://github.com/gitleaks/gitleaks) is free; scan your whole history with it (as a container, from [Module 5](../05-containers/)):

```bash
cd ~/my-security-portfolio
sudo docker run --rm -v "$PWD:/repo:ro" ghcr.io/gitleaks/gitleaks:latest git /repo
```

(In a pipeline you'd pin that image by digest, as in [Module 5](../05-containers/07-pin-by-digest.md). For a one-off local scan, the tag is fine.)

Did either one find the fake `aws_secret=FAKE-1234` from Module 0? (It shouldn't: you never pushed it.) Did they agree? In Module 8, a scanner like this runs on every push.

## Check yourself

1. Why create the secret with the AWS CLI instead of in OpenTofu?
   <details><summary>Answer</summary>

   OpenTofu stores every value it manages in its state file, in plain text. The `.tf` files should only know the secret's name.
   </details>

2. What's wrong with putting a secret in a Lambda environment variable?
   <details><summary>Answer</summary>

   Anyone who can read the function's configuration sees it in plain text, and it ends up in your IaC code and state.
   </details>

3. The admin token leaks. What do you do?
   <details><summary>Answer</summary>

   Treat it as stolen and rotate it right away (`put-parameter --overwrite` with a new random value). No code change is needed. Then find out how it leaked.
   </details>

## Go deeper

- [AWS Systems Manager Parameter Store](https://docs.aws.amazon.com/systems-manager/latest/userguide/systems-manager-parameter-store.html): SecureString parameters and how KMS encrypts them.
- [OWASP Secrets Management Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Secrets_Management_Cheat_Sheet.html): the full picture, from storage to rotation.
