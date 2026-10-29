# The pipeline's identity: lets GitHub Actions deploy the notes app with no stored AWS keys (OIDC).
# Applied once, by you, and kept: `tofu destroy` in ../infra doesn't touch it.
terraform {
  required_version = ">= 1.10"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

  backend "s3" {
    bucket       = "notes-tfstate-123456789012"
    key          = "pipeline/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}

provider "aws" {
  region = "us-east-1"

  default_tags {
    tags = {
      Project   = "notes-app-pipeline"
      ManagedBy = "opentofu"
    }
  }
}

data "aws_caller_identity" "current" {}

variable "github_repo" {
  description = "The repository allowed to deploy, as owner/name"
  type        = string
  default     = "yourname/my-security-portfolio"
}

resource "aws_iam_openid_connect_provider" "github" {
  url            = "https://token.actions.githubusercontent.com"
  client_id_list = ["sts.amazonaws.com"]
}

# Plan: runs on every push to main, read-only, plus the state lock
resource "aws_iam_role" "gha_plan" {
  name = "gha-notes-plan"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Federated = aws_iam_openid_connect_provider.github.arn }
      Action    = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          "token.actions.githubusercontent.com:sub" = "repo:${var.github_repo}:environment:plan"
        }
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "gha_plan_read" {
  role       = aws_iam_role.gha_plan.name
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}

resource "aws_iam_role_policy" "gha_plan_lock" {
  name = "state-lock"
  role = aws_iam_role.gha_plan.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["s3:PutObject", "s3:DeleteObject"]
      Resource = "arn:aws:s3:::notes-tfstate-${data.aws_caller_identity.current.account_id}/notes-app/terraform.tfstate.tflock"
    }]
  })
}

# Apply: only from the production environment, which requires a human approval
resource "aws_iam_role" "gha_deploy" {
  name = "gha-notes-deploy"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Federated = aws_iam_openid_connect_provider.github.arn }
      Action    = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          "token.actions.githubusercontent.com:sub" = "repo:${var.github_repo}:environment:production"
        }
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "gha_deploy" {
  role       = aws_iam_role.gha_deploy.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}
