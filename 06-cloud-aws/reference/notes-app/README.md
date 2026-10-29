# Reference: the notes app

This is where the notes app ends up after [Module 6](../../) (the app), [Module 7](../../../07-identity/) (identity), and [Module 8](../../../08-security-concepts/) (hardening, pipeline). **Build it yourself first.** Use this copy to check your work, or to get unstuck after the [20-minute rule](../../../00-start-here/05-getting-unstuck.md).

Because it's the **final** state, some things differ from what a Module 6 lesson shows. For example, the delete route uses IAM authentication instead of an admin token (Module 8, lesson 3), and there's no SSH key or port 22 (Module 8, lesson 7).

> **Last verified:** 2026-10-29. `infra/` and `pipeline/` are validated with OpenTofu 1.13 and the AWS provider 6.x (`tofu validate`), `infra/` passes Checkov 3.4.0 with `.checkov.yaml`, and the Lambda code is tested locally against stubbed AWS clients. Not applied to a live account by the course; if anything fails for you, [open an issue](../../../../../issues/new/choose).

## Layout

| Folder | What | Lifecycle |
|---|---|---|
| `infra/` | The app: S3, CloudFront, API Gateway, Lambda, DynamoDB, SQS, VPC, the lab server, team and AI roles | Destroyed at the end of every session |
| `pipeline/` | GitHub Actions' OIDC provider and its plan and deploy roles | Applied once and kept |
| `lambda/` | The two functions' code | |
| `frontend/` | The web page | |

## Deploy (after Module 8)

1. Create the state bucket once ([Module 8, lesson 13](../../../08-security-concepts/13-secure-pipeline.md)), and put its name in the `backend "s3"` blocks in `infra/main.tf` and `pipeline/main.tf`.
2. Set `github_repo` in `pipeline/main.tf` to your repository.
3. From each folder, signed in with `aws login` and `AWS_PROFILE=lab`:

   ```bash
   cd pipeline && tofu init && tofu apply
   cd ../infra && tofu init && tofu apply
   ```

After that, pushes to `main` deploy through the pipeline, with your approval.

## Destroy

```bash
cd infra && tofu destroy
```

Leave `pipeline/` and the state bucket in place; they cost nothing (IAM) or nearly nothing (a few kilobytes of state).
