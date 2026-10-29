terraform {
  required_version = ">= 1.10"

  # Remote state (Module 8): encrypted, versioned, private, and locked while in use.
  # Change the bucket name to yours.
  backend "s3" {
    bucket       = "notes-tfstate-123456789012"
    key          = "notes-app/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.8"
    }
  }
}

provider "aws" {
  region = var.region

  default_tags {
    tags = {
      Project   = "notes-app"
      ManagedBy = "opentofu"
    }
  }
}

data "aws_caller_identity" "current" {}
