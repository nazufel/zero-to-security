# A secure delivery pipeline

**Pillars:** ☁️ Cloud · 🪪 Identity · 🤖 AI

## Why this matters

So far, everything has been deployed from your VM, by you. At a company, code ships through a **CI/CD pipeline**: every push is tested and scanned automatically, and changes reach production only through that path. Done well, the pipeline is a security control: nothing ships unscanned, and every change is recorded.

Done badly, it's the softest target in the company. A pipeline holds the keys to production, and the classic way to give it those keys, an access key pasted into the CI system's settings, is the `ci-deploy` story from [Module 7](../07-identity/02-principals.md). This lesson builds the version with **no stored keys at all**.

## The pipeline

```text
push ──► test ──┐
                ├──► plan ──► [a human approves] ──► deploy
push ──► scan ──┘
        (secrets, image CVEs)
```

1. **Test:** `logslayer`'s pytest suite
2. **Scan:** gitleaks for secrets, then build the Chainguard `logslayer` image and scan it with Grype
3. **Plan:** `tofu plan`, as a read-only role
4. **Deploy:** `tofu apply`, as a deploy role, only after you approve it in GitHub

The AWS login uses **OIDC**: for each run, GitHub issues a short-lived signed token that says "this is a job in repo X, branch Y, environment Z." AWS checks the signature, checks the claims against a role's trust policy, and hands back temporary credentials. Nothing to store, nothing to leak, and a token from any other repository is useless.

## Do it

### 1. Move state somewhere the pipeline can reach

Your state file lives in your VM. The pipeline needs it too, and it must stay private ([Module 6, lesson 3](../06-cloud-aws/03-opentofu-basics.md)). Make an encrypted, versioned, private bucket for it, by hand, because OpenTofu can't store its own state in a bucket it hasn't created yet:

```bash
ACCT=$(aws sts get-caller-identity --query Account --output text)
STATE_BUCKET="notes-tfstate-$ACCT"
aws s3api create-bucket --bucket "$STATE_BUCKET"
aws s3api put-bucket-versioning --bucket "$STATE_BUCKET" --versioning-configuration Status=Enabled
aws s3api put-public-access-block --bucket "$STATE_BUCKET" \
  --public-access-block-configuration BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true
echo "$STATE_BUCKET"
```

(If your region isn't `us-east-1`, add `--create-bucket-configuration LocationConstraint=<your-region>` to `create-bucket`.)

In `notes-app/infra/main.tf`, add a backend inside the `terraform` block, with **your** bucket name:

```hcl
  # Remote state: encrypted, versioned, private, and locked while in use.
  backend "s3" {
    bucket       = "notes-tfstate-123456789012"
    key          = "notes-app/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
```

`use_lockfile` makes OpenTofu write a lock file next to the state while it runs, so you and the pipeline can't change things at the same time and corrupt it. Move your state in:

```bash
cd ~/my-security-portfolio/notes-app/infra
tofu init -migrate-state
```

Answer `yes`. Your local `terraform.tfstate` is now copied to the bucket. Delete the local copy (`rm terraform.tfstate*`); it can contain secrets and it's no longer used.

### 2. Give the pipeline its identity

The pipeline's roles live in their own folder, `notes-app/pipeline/`, with their own state. That way your daily `tofu destroy` in `infra/` tears down the app, but not the pipeline's ability to rebuild it. Create `notes-app/pipeline/main.tf`, using the [reference copy](../06-cloud-aws/reference/notes-app/pipeline/main.tf), and change two things: the backend bucket name, and the `github_repo` default to your own `yourname/my-security-portfolio`.

Read the two roles' trust policies closely:

```hcl
Condition = {
  StringEquals = {
    "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
    "token.actions.githubusercontent.com:sub" = "repo:${var.github_repo}:environment:production"
  }
}
```

The `sub` claim must match **exactly**: your repository, and the `production` environment. A token from a fork, another repository, or a job without that environment is refused. The plan role trusts the `plan` environment and gets read-only access plus the state lock. The deploy role trusts `production` and gets admin, because deploying creates IAM roles. That's the most powerful identity you've made, which is why reaching it requires a human (step 3).

```bash
cd ../pipeline
tofu init
tofu apply
```

### 3. Set up GitHub

In your portfolio repo on github.com:

1. **Settings → Secrets and variables → Actions → Variables → New repository variable**: `AWS_ACCOUNT_ID`, with your account ID. (Not a secret: the role ARNs aren't sensitive. No secrets needed at all.)
2. **Settings → Environments → New environment**: `plan`. No protection rules.
3. **New environment**: `production`. Under **Deployment protection rules**, check **Required reviewers** and add yourself. Under **Deployment branches**, choose **Selected branches** and add `main`.

Environments with required reviewers are free on public repositories.

### 4. Write the workflow

Create `.github/workflows/notes-app.yml` in your portfolio, from the [reference copy](reference/notes-app.yml), and leave out the `Infrastructure code (Checkov)` step for now (lesson 14 adds it). Read it job by job:

- `permissions: contents: read` at the top: the default token can only read the repo. Least privilege for the pipeline itself.
- Every `uses:` is pinned to a **commit SHA**, with the version as a comment. That's the lesson of the [Trivy compromise](../05-containers/07-pin-by-digest.md): a tag can be moved to malware; a SHA can't. Dependabot (lesson 8) keeps them up to date.
- The gitleaks image is pinned by digest, for the same reason.
- `plan` and `deploy` each declare an `environment` and `id-token: write`, the permission to request the OIDC token. Only those two jobs can talk to AWS.
- `deploy` needs `plan`, and its environment needs your approval.

### 5. Ship it

```bash
cd ~/my-security-portfolio
git add .github/workflows/notes-app.yml notes-app/infra/main.tf notes-app/pipeline/main.tf
git commit -m "Secure delivery pipeline with OIDC"
git push
```

Open the **Actions** tab and watch. `test` and `scan` run in parallel, then `plan` assumes its role and prints the plan. Read it. Then `deploy` waits: **Review deployments → production → Approve**. Only then does it apply.

Afterward, find the pipeline in CloudTrail:

```bash
aws cloudtrail lookup-events --lookup-attributes AttributeKey=EventName,AttributeValue=AssumeRoleWithWebIdentity \
  --max-results 5 --output json | jq -r '.Events[].CloudTrailEvent | fromjson | "\(.eventTime) \(.userIdentity.userName // .userIdentity.principalId)"'
```

Every deploy, traceable to a GitHub repository and a run, with no long-lived key anywhere.

## Break it

Make the pipeline catch a secret. On a new branch, commit a fake key and open a pull request:

```bash
git switch -c test-leak
echo 'PAYMENT_API_KEY = "8f3a9c1e7b2d4f6a0c5e9b1d3f7a2c4e"' > leak-test.env
git add leak-test.env && git commit -m "test: leak a fake secret"
git push -u origin test-leak
gh pr create --fill
```

The `scan` job fails at **Secrets (gitleaks)**. On a real team, a branch rule would block merging until it passes. Notice what didn't happen: `plan` and `deploy` never ran, because they only run on `main`, and a pull request's token doesn't match either role's trust policy.

Clean up: close the PR, delete the branch (`git switch main && git branch -D test-leak && git push origin --delete test-leak`). The fake key reached GitHub, so in real life it would now be **compromised**: revoke it, even though the scan caught it.

## With Claude

Ask Claude Code:

```text
Review .github/workflows/notes-app.yml and notes-app/pipeline/main.tf as a
CI/CD security reviewer. Look for: unpinned actions or images, excessive
token permissions, trust policies that are too broad, ways a pull request
could reach production, and anything that could leak credentials.
```

**Check the work:** check each finding against the files. Common good catches: the deploy role's `AdministratorAccess` (true, and deliberate, with mitigations; is Claude's suggested narrower policy realistic for a job that creates IAM roles?), and `pull_request` workflows running on untrusted code (they do; they get no OIDC token and no secrets, which is the mitigation). A common **wrong** suggestion: switching the trust condition to `StringLike` with `repo:yourname/*`, which lets **any** of your repositories deploy. Reject that one, and log it.

## Check yourself

1. How does the pipeline get AWS credentials without a stored key?
   <details><summary>Answer</summary>

   OIDC: GitHub issues a signed, short-lived token for the run, and AWS exchanges it for temporary role credentials, but only if the token's claims match the role's trust policy.
   </details>

2. Why does the deploy role trust only `repo:yourname/my-security-portfolio:environment:production`?
   <details><summary>Answer</summary>

   So only jobs in that repository, running in the production environment (which requires a human approval and only allows `main`), can become it. Forks, other repos, and branches get nothing.
   </details>

3. Why pin actions by commit SHA instead of a version tag?
   <details><summary>Answer</summary>

   A tag can be moved to point at different code, as in the Trivy compromise. A SHA always means the same code.
   </details>

## Go deeper

- [GitHub: security hardening with OpenID Connect](https://docs.github.com/en/actions/security-for-github-actions/security-hardening-your-deployments/about-security-hardening-with-openid-connect)
- [GitHub Actions security hardening](https://docs.github.com/en/actions/security-for-github-actions/security-guides/security-hardening-for-github-actions): permissions, untrusted input, and third-party actions.
