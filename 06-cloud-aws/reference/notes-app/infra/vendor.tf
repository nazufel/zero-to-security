# A role a (pretend) outside vendor assumes to audit the account.
# The External ID stops the vendor from being tricked into using it for someone else.
variable "vendor_external_id" {
  description = "A shared value the vendor must send when assuming the role"
  type        = string
  default     = "notes-app-7f3c9a"
}

resource "aws_iam_role" "vendor" {
  name = "vendor-auditor"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root" }
      Action    = "sts:AssumeRole"
      Condition = {
        StringEquals = { "sts:ExternalId" = var.vendor_external_id }
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "vendor" {
  role       = aws_iam_role.vendor.name
  policy_arn = "arn:aws:iam::aws:policy/SecurityAudit"
}
