# Your Okta org

**Pillars:** 🪪 Identity

## Why this matters

At most companies, you don't log in to each app separately. You log in once to an **identity provider** (IdP), and it vouches for you to email, chat, the HR system, and AWS. That's **single sign-on** (SSO). It means one place to turn on MFA, one place to remove a leaver's access, and one log of every sign-in.

It also means the IdP is the most valuable target in the company, and the help desk is its front door. **Okta** is one of the most common IdPs, and on help desk postings, "Okta" and "Active Directory" appear more than almost anything else. Okta offers a free org for building and testing, which is all you need to practice the job.

## Do it

1. **Sign up for a free Okta org.** Go to [developer.okta.com/signup](https://developer.okta.com/signup/) and create an **Integrator Free Plan** org.

   > **Last verified:** 2026-10-29. The Integrator Free Plan replaced Okta's old Developer Edition in 2025 ([Okta](https://developer.okta.com/blog/2025/05/13/okta-developer-edition-changes)). It's free, it's not for production use, and it has limits on users and features that may change. Check the current limits on the signup page. Everything in this track stays well inside them.

   Use a real email address you control. You'll get an org URL like `https://integrator-1234567.okta.com`. Bookmark the **admin console**: the same URL with `-admin` after the org name.

2. **Protect your admin account first**, the way you protected AWS root in [Module 6](../../06-cloud-aws/01-account-setup.md). You're a **super administrator**: you can do anything, including remove everyone else's access. Set up MFA when it asks, and if you can, choose a **passkey** or security key ([Module 8](../../08-security-concepts/01-foundations.md)).

3. **Tour the admin console.** Find these, without changing anything yet:

   | Menu | What's there | Lesson |
   |---|---|---|
   | **Directory → People** | Every user, and their status | 2 |
   | **Directory → Groups** | Groups, the way access is assigned | 2 |
   | **Security → Authenticators** | Password, Okta Verify, passkeys, and other factors | 4 |
   | **Security → Authentication Policies** | Which factors each app requires | 4 |
   | **Reports → System Log** | Every sign-in, reset, and admin action | 5 |
   | **Applications** | The apps people sign in to through Okta | 6 |

4. **Write the help desk's view** in `okta/notes.md` in your portfolio: for each menu, which common ticket it's where you'd go to solve. ("I can't log in" → People, then System Log.)

## Break it

Find out what your own account can do, and what that means. Open **Security → Administrators**. You have the **Super Administrator** role. Read Okta's description of what it allows.

Now picture the attack in [lesson 3](03-help-desk-tasks.md): someone convinces a help desk agent to reset **your** MFA, then signs in as you. Write in your notes everything they could do with a super admin account: create users, reset anyone's MFA, add an app that sends everyone's sign-ins somewhere else, delete the System Log's evidence by changing settings... That's why admin accounts at real companies get the strongest MFA, and why help desk agents usually **can't** reset an admin's MFA at all.

## With Claude

Ask Claude Code:

```text
I'm learning Okta for a help desk role. What are the first five security
settings an Okta admin should check in a new org, and why?
```

**Check the work:** check each setting exists by finding it in your admin console. Menu names in Okta change over time, and AI training data lags behind, so Claude may describe a menu that's moved or been renamed. When you can't find it, search [Okta's help](https://help.okta.com/) for the setting's name. Note anything Claude got wrong in your [AI check log](../../01-ai-foundations/01-what-ai-is.md).

## Check yourself

1. What is an identity provider, and why does it make offboarding easier?
   <details><summary>Answer</summary>

   A single service that authenticates people and vouches for them to other apps (SSO). Deactivating someone there removes their access to every connected app at once.
   </details>

2. Why protect your Okta admin account before anything else?
   <details><summary>Answer</summary>

   A super admin can change anyone's access and the org's security settings. It's the most valuable account in the org.
   </details>

3. Is the free Okta org suitable for a real company's users?
   <details><summary>Answer</summary>

   No. It's for building and testing, not production.
   </details>

## Go deeper

- [Okta Help Center](https://help.okta.com/): the admin documentation for every screen in this track.
