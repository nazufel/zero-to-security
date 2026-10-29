# A role for Claude Code to use through the AWS MCP server.
# Only you (the admin user) can assume it, and it can only view, never change.
resource "aws_iam_role" "claude" {
  name                 = "claude-readonly"
  max_session_duration = 3600

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/admin" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "claude_view_only" {
  role       = aws_iam_role.claude.name
  policy_arn = "arn:aws:iam::aws:policy/job-function/ViewOnlyAccess"
}

output "claude_role_arn" {
  value = aws_iam_role.claude.arn
}
