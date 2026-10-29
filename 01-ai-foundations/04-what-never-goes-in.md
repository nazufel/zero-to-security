# What never goes in

**Pillars:** 🤖 AI

## Why this matters

In 2023, Samsung engineers pasted confidential source code and internal meeting notes into ChatGPT to get help. Within weeks, Samsung banned AI chatbots on company devices. No hacker was involved. The engineers gave the data away themselves.

Anything you paste into an AI tool leaves your control. It's stored by the provider, it may be reviewed by people, it may be used to train future models depending on your settings and plan, and it could be exposed if the provider is ever breached. And like a Git commit you already pushed, you can't really take it back.

## The rule

**Never paste in:**

| What | Examples |
|---|---|
| **Secrets** | Passwords, API keys, tokens, private keys, connection strings |
| **Personal data** | Names with emails or phone numbers, birth dates, ID numbers, health or financial details |
| **Customer data** | Anything a customer gave your employer, even "just one row" |
| **Your employer's code and documents** | Unless the company has approved that tool for that use |
| **Anything you don't own** | If it's not yours to share, it's not yours to paste |

> **Free AI is often paid for with your data.** When you aren't paying with money, check what you are paying with.

The good news: AI almost never needs the real secret to help you. It needs the *shape* of the problem.

## Do it

1. In [claude.ai](https://claude.ai), open **Settings** and find the **Privacy** section. Read whether your chats can be used to improve models, and choose the setting you're comfortable with. Write down what you chose and why.

   > **Last verified:** 2026-10-29. Settings names and defaults change. If you can't find it, search the [Anthropic Privacy Center](https://privacy.anthropic.com/) for "model training."

2. Here's a prompt a stressed help desk tech might send. **Don't paste it into anything.** Just read it:

   ```text
   Hey, our patient portal login is broken. Here's the config:

   DB_HOST=prod-db-01.internal.brightsmile-dental.com
   DB_USER=admin
   DB_PASSWORD=Spring2026!
   PAYMENT_API_KEY=pk-FAKE-9f8e7d6c5b4a

   It fails when patient Maria Gonzalez (maria.g@example.com, DOB 1984-02-11)
   tries to log in. Error: "connection refused". Why?
   ```

3. Create `ai-foundations/redaction-practice.md`. List every item that must not go to an AI tool, and say why.

   <details><summary>Answer</summary>

   - `DB_HOST`: an internal server name. It tells an attacker what to aim for.
   - `DB_USER` and `DB_PASSWORD`: a working login to the production database.
   - `PAYMENT_API_KEY`: a secret that may be able to move money.
   - The patient's name, email, and date of birth: personal data, and health-related, which carries legal rules in many countries.

   What's left is the part that actually matters: "connection refused" when the app connects to its database.
   </details>

4. Rewrite the prompt so it's safe and still useful. Add it to the same file:

   ```text
   A web app can't connect to its database. The app reads DB_HOST, DB_USER,
   and DB_PASSWORD from a config file. Logins fail with "connection refused".
   What are the most likely causes, and how do I check each one?
   ```

   Notice that nothing useful was lost. "Connection refused" is the clue. The password never was.

## Break it

Can you hide a secret by scrambling it? Encode the fake password:

```bash
echo -n 'Spring2026!' | base64
```

What you should see:

```
U3ByaW5nMjAyNiE=
```

Now ask Claude:

```text
What is this? U3ByaW5nMjAyNiE=
```

Claude decodes it instantly. **Encoding isn't hiding.** Base64 and similar tricks are reversible by anyone, so an encoded secret is still a secret. You'll see this again in Module 4: encoding, hashing, and encryption are three different things, and only one of them keeps secrets.

## With Claude

Here's the trap: you can't paste the real config into Claude and ask it to redact the secrets for you. By then it's already sent. Ask for a checklist instead:

```text
I work help desk. Give me a short checklist to run through before I paste
anything into an AI tool, so I don't leak secrets or personal data.
```

**Check the work:** does the checklist catch everything you found in step 3, including the internal hostname? Hostnames and internal URLs get missed a lot. Add anything missing.

```bash
git add ai-foundations/redaction-practice.md
git commit -m "Add redaction practice"
git push
```

## Check yourself

1. You need help with an error from a script that contains an API key. What do you paste?
   <details><summary>Answer</summary>

   The error and the relevant code, with the key replaced by a placeholder like `<API_KEY>`. AI needs the shape of the problem, not the secret.
   </details>

2. You accidentally paste a real password into an AI chat. You delete the chat right away. Are you safe?
   <details><summary>Answer</summary>

   No. It was already sent to the provider. Treat the password as stolen and change it, just like a secret pushed to GitHub.
   </details>

3. A coworker says, "It's fine, I base64-encoded the customer list first." Is it fine?
   <details><summary>Answer</summary>

   No. Base64 is encoding, not encryption. Anyone, including the AI, can decode it in a second.
   </details>

## Go deeper

- [OWASP: Sensitive Information Disclosure](https://genai.owasp.org/llmrisk/llm022025-sensitive-information-disclosure/): the risk from this lesson, from the provider's side. You'll meet the full list in [lesson 6](06-owasp-llm-top-10.md).
