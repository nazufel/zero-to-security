# Phishing analysis

**Pillars:** 🪪 Identity

## Why this matters

Phishing is how most attacks on people start, and "is this email real?" is the most common ticket in both help desk and SOC work. Attackers don't need to break your AWS account if they can trick someone into typing the password into a fake login page. The Uber breach in [Module 8](../08-security-concepts/01-foundations.md) started with a stolen password; most stolen passwords start with a phish.

The skill is examining a suspicious email **safely**: getting every answer you need from its text and headers without ever clicking, opening, or running anything in it.

## Do it

1. **Get the sample.** It's a realistic phishing email sent to someone at a dental office, written for this course. Treat it as hostile anyway: that's the habit.

   ```bash
   mkdir -p ~/phish && cd ~/phish
   curl -fsSLO https://raw.githubusercontent.com/nazufel/zero-to-security/main/09-incident-response/samples/phish.eml
   ```

   An `.eml` file is the raw email, as plain text. Never double-click one on a real work machine; your mail app might render it, load images, or worse. Read it in a terminal.

2. **Read the headers that matter:**

   ```bash
   grep -E '^(From|Reply-To|Return-Path|To|Subject|Date):' phish.eml
   ```

   ```
   Return-Path: <billing@rnicrosoft-support.example>
   From: "Microsoft 365 Billing" <billing@microsoft.com>
   Reply-To: "Microsoft 365 Billing" <billing-desk@rnicrosoft-support.example>
   ...
   ```

   The **From** says Microsoft. The **Return-Path** (where the mail really came from) and **Reply-To** (where your answer would go) say `rnicrosoft`, with an **r-n** that looks like an **m**. The display name and From address are just text; anyone can type anything there.

3. **Check the authentication results.** The receiving mail server checked whether the sender was allowed to send for that domain:

   ```bash
   sed -n '/^Authentication-Results/,/^From:/p' phish.eml
   ```

   - **SPF fail:** the sending server isn't on the domain's list of allowed senders. (SPF is a DNS TXT record, which you looked up with `dig` in [Module 4](../04-networking/04-dns.md).)
   - **DKIM none:** the message isn't cryptographically signed.
   - **DMARC fail:** the visible From domain (`microsoft.com`) doesn't match what was authenticated.

   Three failures. A real Microsoft billing email would pass all three.

4. **Find where the link really goes**, without clicking it:

   ```bash
   grep -o 'href="[^"]*"' phish.eml
   grep -o '>https[^<]*<' phish.eml
   ```

   The text you'd **see** is `https://login.microsoftonline.com/...`, a real Microsoft address. The `href`, where it actually **goes**, is `rnicrosoft-support.example`. In a mail app, hovering shows the real destination. In a terminal, you see it directly.

5. **Examine the attachment safely.** `Invoice_0314.pdf.html` is a double extension: it looks like a PDF, and it's a web page. Extract it as text, never open it in a browser:

   ```bash
   awk '/^PGh0/,/^$/' phish.eml | tr -d '\n' | base64 -d > attachment.txt
   cat attachment.txt
   sha256sum attachment.txt
   ```

   A fake Microsoft sign-in form that posts your email and password to the attacker's site. Encoding, not encryption, again ([Module 4](../04-networking/07-crypto-basics.md)): the attachment was base64 so it could travel through email. The SHA-256 hash is how a SOC shares and searches for a file (in threat intelligence feeds, and in other users' mailboxes) without passing the file around.

6. **Write the analysis.** Create `incidents/phishing-analysis.md` with: the verdict (phishing, yes or no), every indicator you found and how you found it, the **indicators of compromise** (IOCs) someone could block or search for (domains, IP address, file hash, subject line), and what to do next:

   - Block the sender domain and the link domain
   - Search all mailboxes for the same subject, sender, or attachment hash
   - **Ask the reporter, and everyone else who got it, whether they clicked or entered anything.** If anyone entered a password: reset it now, check their sign-ins, and declare an incident.
   - Thank the person who reported it

## Break it

The email says the mailbox will be deleted "within 24 hours." It's Saturday morning. Write down the pressure tactics in this email: urgency, fear of loss, authority (Microsoft), and timing (a weekend, when IT is slower to answer). Then answer honestly: if you were tired, on your phone, on a Saturday, would you have caught the **r-n**?

Phishing works on smart people because it targets moments, not intelligence. That's why the technical fixes matter more than training alone: **phishing-resistant MFA** (passkeys) means a stolen password from that fake form is useless by itself ([Module 8](../08-security-concepts/01-foundations.md)).

## With Claude

Ask Claude Code to analyze it too, but read [what never goes in](../01-ai-foundations/04-what-never-goes-in.md) first. This sample is fake and safe to share. A real phishing email often contains a real employee's name, address, and sometimes data the attacker already stole. At work, follow your company's AI policy before pasting one anywhere.

```text
Read ~/phish/phish.eml as text. Is it phishing? List every indicator you
find, the IOCs to block, and a short note to send the employee who reported
it. Don't follow or fetch any links.
```

**Check the work:** compare its indicators with yours. Did it catch the r-n lookalike, the SPF/DKIM/DMARC failures, the mismatched link, and the double extension? Did it try to fetch the link domain to "check" it? (You told it not to; check the transcript. Visiting an attacker's link from your machine tells them you're looking.) Is its note to the employee kind, and clear about what to do if they clicked?

## Check yourself

1. The From line shows `billing@microsoft.com`. Is that proof it's from Microsoft?
   <details><summary>Answer</summary>

   No. The From line is just text the sender wrote. Check the Return-Path, Reply-To, and the SPF/DKIM/DMARC results.
   </details>

2. How do you see where a link goes without clicking it?
   <details><summary>Answer</summary>

   Hover over it in a mail client, or read the raw message and look at the `href`, which can differ completely from the text shown.
   </details>

3. A user says they entered their password on the page. What happens now?
   <details><summary>Answer</summary>

   Reset the password immediately, revoke their sessions, check their recent sign-ins and activity, and declare an incident. Then find who else received it.
   </details>

## Go deeper

- [CISA: avoiding social engineering and phishing attacks](https://www.cisa.gov/news-events/news/avoiding-social-engineering-and-phishing-attacks)
- Dig Deeper: email security with SPF, DKIM, and DMARC. They're just DNS records you can read with `dig`.
