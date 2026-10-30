# Dig Deeper: Okta (identity for the help desk)

**Pillars:** 🪪 Identity · ☁️ Cloud

> **Optional track, for help desk roles.** Do [Module 7](../../07-identity/) first. Lesson 6 also uses the notes app from [Module 6](../../06-cloud-aws/).

## Why this matters

At most companies, people sign in once, to an identity provider, and it vouches for them everywhere else. Okta is one of the most common, and it's on a large share of help desk postings. It's also where the help desk meets security head-on: password and MFA resets are both the most common tickets and one of the most attacked paths into a company.

## Opinions

- **Okta's free Integrator plan**, for building and testing. Not for production, and it has limits; this track stays inside them.
- **Verify the caller before every reset.** The help desk script in lesson 3 is the most important page in this track.
- **Passkeys for admins first**, then everyone.
- **AWS through SSO, not IAM users**, finishing the story from Module 7.

## Ready to put it on your resume when…

- [ ] You can create, move, suspend, and deactivate users, and assign access through groups
- [ ] You can unlock an account and reset a password or MFA, following a verification script
- [ ] You can explain why help desk MFA resets are targeted, with a real example
- [ ] You can set an authentication policy that requires phishing-resistant MFA for admins
- [ ] You can find out why a user can't sign in from the System Log, and spot an account takeover pattern
- [ ] You can set up SAML single sign-on from Okta into AWS, with a role instead of IAM users

Then list it [honestly](../../10-capstone-and-hired/07-listing-dig-deeper-honestly.md): "hands-on lab experience with Okta: user lifecycle, MFA policy, System Log investigation, and SAML SSO into AWS."

## Lessons

1. [Your Okta org](01-your-okta-org.md): a free org, admin MFA, and a tour of the admin console
2. [Users and groups](02-users-and-groups.md): joiners, movers, and leavers
3. [Help desk tasks](03-help-desk-tasks.md): resets, unlocks, and verifying the caller. *(The MGM help desk attack.)*
4. [MFA and passkeys](04-mfa-and-passkeys.md): phishing-resistant MFA, as policy
5. [The System Log](05-system-log.md): why a user can't sign in, and what an account takeover looks like
6. [Single sign-on into AWS](06-sso-into-aws.md): SAML, a role, and no IAM users

## Practice

- [Quiz](quiz.md)
- [Project: a help desk runbook](project.md)
