# Users and groups

**Pillars:** 🪪 Identity

## Why this matters

Help desk identity work has a name: **joiners, movers, and leavers**. Someone starts and needs accounts. Someone changes teams and needs different access. Someone leaves and must lose everything, today. The leaver step is the one that gets missed, and forgotten accounts of former employees and contractors show up in breach reports again and again.

You did this on one Linux server in [Module 2](../../02-linux/07-users-and-groups.md), and in AWS in [Module 7](../../07-identity/03-groups.md). In an IdP, it's the same rule, for every app at once: **access through groups, never one person at a time.**

## Do it

1. **Make the groups.** In **Directory → Groups → Add group**, create three: `Help Desk`, `Accounting`, and `AWS View Only`. (The last one gets used in lesson 6.)

2. **A joiner.** In **Directory → People → Add person**, add `Jordan Lee`, in Accounting. Use an email address you can receive at, like `you+jordan@yourmail.com` (most email providers deliver `+` addresses to you). Add Jordan to the `Accounting` group, and choose to send an activation email.

   Look at Jordan's **status**. Okta users move through states:

   | Status | Means |
   |---|---|
   | **Staged** | Created, not yet sent an activation |
   | **Pending user action** | Activation sent, not yet completed |
   | **Active** | Can sign in |
   | **Password reset** | Must set a new password at next sign-in |
   | **Locked out** | Too many failed sign-ins |
   | **Suspended** | Temporarily blocked; everything kept |
   | **Deactivated** | Can't sign in; removed from apps |

   Open the activation email and finish setting up Jordan, so you can test as them later. Use a **different browser** (or a private window) for Jordan, so you stay signed in as admin in your main one.

3. **A mover.** Jordan moves from Accounting to Help Desk. Remove them from `Accounting` and add them to `Help Desk`. That's the whole change: everything tied to Accounting goes, everything tied to Help Desk arrives. Write in `okta/notes.md` what would have gone wrong if Accounting's app access had been assigned to Jordan directly instead of through the group.

4. **A leaver, done right.** Add a second test user, `Sam Patel`, and activate them. Then Sam leaves the company today. In order:

   1. **Suspend** Sam immediately, so they can't sign in, while nothing is deleted.
   2. Check the System Log for Sam's recent activity (lesson 5).
   3. **Deactivate** Sam once you're sure nothing needs to be kept. Deactivation removes them from apps and ends their access everywhere Okta controls.

   It's the [Module 2](../../02-linux/07-users-and-groups.md) rule: lock first, delete later, because deleting first can destroy what an investigation needs.

## Break it

Find the leaver that slips through. Imagine Sam also had an account created **directly** in an app (say, a shared vendor portal), not through Okta. Deactivate Sam in Okta. What happens to that other account?

Nothing. Okta only controls what Okta manages. Sam can still log in to the vendor portal with a password Okta never knew about. This is one of the most common real offboarding failures: apps that aren't connected to the IdP, or "local" admin accounts someone made for convenience. It's why companies try to put **every** app behind SSO, and why offboarding checklists include "accounts outside the IdP." Write your own leaver checklist in `okta/notes.md`, with that line on it.

## With Claude

Ask Claude Code:

```text
Write a short offboarding checklist for a help desk using Okta, for an
employee who leaves today. Include what to do first, what to check, and
what to do last. Assume some apps aren't connected to Okta.
```

**Check the work:** does it suspend before deactivating? Does it check for active sessions and devices, apps outside Okta, shared accounts the person knew the password to, and forwarded email? Does it mention transferring files before deletion? Compare with yours, and merge the best of both. Does it invent an Okta feature? Check anything you can't find in the admin console.

## Check yourself

1. What are joiners, movers, and leavers?
   <details><summary>Answer</summary>

   The three identity lifecycle events: someone starts, someone changes role, someone leaves. Each needs access granted, changed, or removed.
   </details>

2. Suspend or deactivate, first?
   <details><summary>Answer</summary>

   Suspend first: it blocks sign-in immediately while keeping everything for review. Deactivate once nothing more needs to be kept.
   </details>

3. You deactivate someone in Okta. Can they still get into anything?
   <details><summary>Answer</summary>

   Yes, any account that isn't managed through Okta, like an app with its own local login. Offboarding must check those too.
   </details>

## Go deeper

- [Okta: user lifecycle states](https://help.okta.com/en-us/content/topics/users-groups-profiles/usgp-end-user-states.htm)
