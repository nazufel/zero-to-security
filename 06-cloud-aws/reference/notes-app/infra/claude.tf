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

# A narrower role for one job: helping debug the notes app's functions.
resource "aws_iam_role" "claude_debugger" {
  name                 = "claude-notes-debugger"
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

resource "aws_iam_role_policy" "claude_debugger" {
  name = "debug-notes-functions"
  role = aws_iam_role.claude_debugger.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "ListFunctions"
        Effect   = "Allow"
        Action   = "lambda:ListFunctions"
        Resource = "*" # ListFunctions can't be limited to specific functions
      },
      {
        Sid      = "SeeNotesFunctions"
        Effect   = "Allow"
        Action   = "lambda:GetFunctionConfiguration"
        Resource = "arn:aws:lambda:${var.region}:${data.aws_caller_identity.current.account_id}:function:${var.name}-*"
      },
      {
        Sid      = "ReadNotesLogs"
        Effect   = "Allow"
        Action   = ["logs:FilterLogEvents", "logs:DescribeLogStreams"]
        Resource = "arn:aws:logs:${var.region}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/${var.name}-*"
      },
      {
        Sid      = "NeverReadSecrets"
        Effect   = "Deny"
        Action   = ["ssm:GetParameter*", "secretsmanager:GetSecretValue", "kms:Decrypt"]
        Resource = "*"
      },
    ]
  })
}

output "claude_debugger_role_arn" {
  value = aws_iam_role.claude_debugger.arn
}
