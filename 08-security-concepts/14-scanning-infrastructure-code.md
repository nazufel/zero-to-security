# Scanning infrastructure code

**Pillars:** ☁️ Cloud · 🤖 AI

## Why this matters

**OWASP A02, Security Misconfiguration**, is mostly a cloud problem now: a bucket made public, a security group open to the world, logging turned off. Every one of those is a line in an infrastructure file, which means a scanner can catch it **before** `tofu apply`, in the pipeline, the same way Grype catches a vulnerable package.

The scanner is the easy part. The skill is what comes after: dozens of findings, some real, some irrelevant, some wrong. You'll sort them, fix what matters, and write down why you're accepting the rest.

## Do it

1. **Scan your infrastructure** with [Checkov](https://www.checkov.io/), a free, open-source IaC scanner. `uvx` runs it without installing anything, pinned to a version:

   ```bash
   cd ~/my-security-portfolio/notes-app
   uvx checkov@3.4.0 --directory infra --framework terraform --compact --quiet
   ```

   > **Last verified:** 2026-10-29 with Checkov 3.4.0.

   Expect around 50 failed checks. The summary at the end shows passed and failed counts. Don't panic, and don't fix anything yet.

2. **Get the list in one screen**, grouped by check:

   ```bash
   uvx checkov@3.4.0 --directory infra --framework terraform --quiet -o json \
     | jq -r '.results.failed_checks[] | "\(.check_id)\t\(.check_name)"' | sort | uniq -c | sort -rn
   ```

3. **Triage every check into one of four buckets**, in `security/iac-findings.md`:

   | Bucket | Means | Examples you'll find |
   |---|---|---|
   | **Fix** | Real, and worth it | NACL lets RDP in; default security group isn't locked down; no point-in-time recovery on the table |
   | **Accept: cost** | Real, but costs money this lab won't spend | WAF, customer-managed KMS keys, cross-region replication |
   | **Accept: design** | A deliberate choice, with a reason | Public `GET /notes`; Lambda outside a VPC |
   | **Later / false positive** | Coming in Module 9, or the scanner is wrong | Flow logs, X-Ray, access logs; a check that misses something you did |

   Write one reason per check. "Because it's a lab" isn't a reason. "Costs about $5/month; throttling covers abuse" is.

4. **Fix the real ones.** Work through them with the [reference copy](../06-cloud-aws/reference/notes-app/infra/) as a guide. The one that should make you sit up is `CKV_AWS_231`: **"Ensure no NACL allow ingress from 0.0.0.0:0 to port 3389."** Your NACL's return-traffic rule from [Module 6](../06-cloud-aws/10-networking-in-aws.md) allows ports 1024–65535 from anywhere, and **3389 (Windows Remote Desktop) is in that range**. Linux only uses 32768 and up for return traffic. Change `from_port` to `32768`, and the scanner found a real hole you wrote yourself, two modules ago, that no one noticed.

   The others in the reference: lock down the default security group (`aws_default_security_group` with no rules), point-in-time recovery on the table, a lifecycle rule and versioning on the buckets, egress on the lab server limited to 80 and 443, and AWS's managed security headers on CloudFront.

5. **Record the accepted ones** in `notes-app/infra/.checkov.yaml`, one line each, with the reason as a comment. Start from the [reference config](../06-cloud-aws/reference/notes-app/infra/.checkov.yaml) and **change any reason you disagree with**. This file is now a reviewed list of accepted risks, in version control, where an auditor can read it.

6. **Rescan** until it's clean:

   ```bash
   uvx checkov@3.4.0 --directory infra --config-file infra/.checkov.yaml
   ```

   ```
   Passed checks: 188, Failed checks: 0, Skipped checks: 0
   ```

7. **Add it to the pipeline.** In `.github/workflows/notes-app.yml`, add to the `scan` job:

   ```yaml
         - uses: astral-sh/setup-uv@68559e99cc807c1eb7e9238fd43a15bba460eec2 # v10.3.3
         - name: Infrastructure code (Checkov)
           run: uvx checkov@3.4.0 --directory notes-app/infra --config-file notes-app/infra/.checkov.yaml
   ```

   Commit everything and push. `tofu plan` now only runs on infrastructure code that has passed the scan.

## Break it

The challenge from this module's plan: make the pipeline catch an **over-permissive IAM policy**. On a branch, give the notes Lambda's role a "temporary" shortcut in `lambda.tf`:

```hcl
      {
        Effect   = "Allow"
        Action   = "s3:*"
        Resource = "*"
      },
```

Run the scan locally first:

```bash
uvx checkov@3.4.0 --directory infra --config-file infra/.checkov.yaml
```

New failures appear, about permissions without constraints and possible data exfiltration, on `aws_iam_role_policy.notes`. Push the branch and open a pull request: the `scan` job fails, and nothing gets near `plan`. Between lesson 13 and this lesson, the pipeline now catches both things the plan promised: **a fake secret, and an over-permissive policy**. Close the PR and delete the branch.

## With Claude

Ask Claude Code to do the triage you did by hand, then compare:

```text
Run `uvx checkov@3.4.0 --directory infra --framework terraform --quiet -o json`
and triage every failed check into: fix, accept for cost, accept for design,
or later/false positive. One-line reason each. Then propose fixes for the
"fix" bucket as a diff, without applying.
```

**Check the work:**

- Where Claude's bucket differs from yours, who's right? Make it argue its case.
- For every fix it proposes, run `tofu plan` (after copying its diff in) and read it. Does a "fix" **cost money** (a NAT gateway for "Lambda in a VPC," a WAF), or destroy and recreate something?
- Did it suggest "skip it" for something you decided to fix, like the RDP rule? An AI that's eager to make a scanner go quiet is a real risk. The goal is fewer **real** problems, not fewer findings.

## Check yourself

1. What does an IaC scanner catch that an image scanner doesn't?
   <details><summary>Answer</summary>

   Misconfigurations in cloud resources, like public buckets, open security groups, missing encryption, or missing logging, before they're deployed.
   </details>

2. Is it OK to skip a finding?
   <details><summary>Answer</summary>

   Yes, when it's a deliberate decision with a written reason, kept in version control and reviewed. Skipping to make the scanner quiet is not.
   </details>

3. What did `CKV_AWS_231` find in your network, and why did nobody notice it?
   <details><summary>Answer</summary>

   The NACL's return-traffic rule (1024–65535 from anywhere) also allowed RDP on 3389. It looked like a normal "ephemeral ports" rule, and nothing was listening on 3389 to make it obvious.
   </details>

## Go deeper

- [Checkov documentation](https://www.checkov.io/1.Welcome/What%20is%20Checkov.html): suppressing checks inline, custom policies, and other frameworks.
