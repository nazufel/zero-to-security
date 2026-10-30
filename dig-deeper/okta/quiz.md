# Okta quiz

Answer each question out loud or on paper *before* you open the answer.

1. An employee leaves today. What do you do first in Okta, and why not delete them?
   <details><summary>Answer</summary>

   Suspend them, which blocks sign-in immediately and keeps everything. Deactivate once nothing more needs to be kept. Deleting first can destroy evidence.
   </details>

2. Someone moves from Accounting to Help Desk. What changes in Okta?
   <details><summary>Answer</summary>

   Their group membership: out of Accounting, into Help Desk. Access follows the groups, so nothing is assigned person by person.
   </details>

3. A caller says they're locked out, gives their employee ID and manager's name, and is in a hurry. What do you do?
   <details><summary>Answer</summary>

   Verify through a channel you start: a callback to the number in HR, or a push to their enrolled device. An ID and a manager's name are easy to find, and urgency is a warning sign.
   </details>

4. What happened at MGM in 2023, and what would have stopped it?
   <details><summary>Answer</summary>

   Attackers impersonated an employee on a call to the help desk and got credentials reset, which led to admin access and ransomware. Verifying the caller through a separate channel, and never resetting admin MFA at the help desk, would have stopped the first step.
   </details>

5. Why is an MFA reset more dangerous than a password reset?
   <details><summary>Answer</summary>

   Whoever signs in next enrolls their own device as the second factor and takes over the account's MFA.
   </details>

6. Which MFA type should admins be required to use, and why?
   <details><summary>Answer</summary>

   A passkey or security key (FIDO2). It's tied to the real site's address, so a phishing page can't use it.
   </details>

7. A user says "I can't log in." Where do you look, and for what?
   <details><summary>Answer</summary>

   The System Log, for that user's failed `user.session.start` events. The outcome reason says why: wrong password, locked out, failed MFA, or a policy block.
   </details>

8. Failed sign-ins, then a success, then a new authenticator enrolled, within minutes. What might it be, and what do you do?
   <details><summary>Answer</summary>

   An account takeover: an attacker with the password adding their own MFA. Suspend the account and contact the user through a verified channel.
   </details>

9. How does Okta give someone access to AWS without an IAM user?
   <details><summary>Answer</summary>

   SAML: Okta sends AWS a signed assertion naming the user and a role. AWS trusts Okta as a SAML provider, and the role's trust policy allows `AssumeRoleWithSAML` from it. The user gets a temporary session.
   </details>

10. You remove someone from the AWS group in Okta. Are they out of AWS?
    <details><summary>Answer</summary>

    For new sign-ins, yes. A session they already started lasts until it expires. For urgent cases, revoke the role's active sessions in IAM.
    </details>

## Challenge

Answer the [help desk mock interview](../../appendix/mock-interviews.md#interview-1-help-desk--it-support) out loud, all ten questions. For questions 2 and 5, use what you did in this track as your example.
