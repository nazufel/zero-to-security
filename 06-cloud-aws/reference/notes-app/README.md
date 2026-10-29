# Reference: the notes app

This is where the [Module 6](../../) lessons and [project](../../project.md) end up. **Build it yourself first.** Use this copy to check your work, or to get unstuck after the [20-minute rule](../../../00-start-here/05-getting-unstuck.md).

> **Last verified:** 2026-10-29. Validated with OpenTofu 1.13 and the AWS provider 6.x (`tofu validate`), and the Lambda code tested locally against stubbed AWS clients. Not applied to a live account by the course; if anything fails for you, [open an issue](../../../../../issues/new/choose).

## Deploy

From `infra/`, signed in with `aws login` and `AWS_PROFILE=lab` ([lesson 1](../../01-account-setup.md)):

```bash
ssh-keygen -t ed25519 -f ~/.ssh/aws_lab -C "lab VM to AWS"     # once
echo "my_ip = \"$(curl -s https://checkip.amazonaws.com)\"" > terraform.tfvars
aws ssm put-parameter --name /notes/admin-token --type SecureString --value "$(openssl rand -hex 32)"   # once
tofu init
tofu apply
```

## Destroy

```bash
tofu destroy
```

The admin token parameter isn't managed by OpenTofu, so it survives `destroy` (and costs nothing). Delete it when you're completely done: `aws ssm delete-parameter --name /notes/admin-token`.
