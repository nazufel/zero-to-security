# The notes app team: people get permissions through groups, never directly.

resource "aws_iam_group" "team" {
  for_each = toset(["developers", "analysts", "auditors"])
  name     = "notes-${each.key}"
}

# Developers: deploy and debug the app's functions, read its logs
resource "aws_iam_group_policy" "developers" {
  name  = "notes-developer"
  group = aws_iam_group.team["developers"].name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "ManageNotesFunctions"
        Effect   = "Allow"
        Action   = ["lambda:GetFunction", "lambda:UpdateFunctionCode", "lambda:InvokeFunction"]
        Resource = "arn:aws:lambda:${var.region}:${data.aws_caller_identity.current.account_id}:function:${var.name}-*"
      },
      {
        Sid      = "DenyCodeChangesWithoutMFA"
        Effect   = "Deny"
        Action   = "lambda:UpdateFunctionCode"
        Resource = "*"
        Condition = {
          BoolIfExists = { "aws:MultiFactorAuthPresent" = "false" }
        }
      },
      {
        Sid      = "ReadNotesLogs"
        Effect   = "Allow"
        Action   = ["logs:FilterLogEvents", "logs:GetLogEvents", "logs:DescribeLogStreams"]
        Resource = "arn:aws:logs:${var.region}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/${var.name}-*"
      },
    ]
  })
}

# Analysts: read notes, nothing else
resource "aws_iam_group_policy" "analysts" {
  name  = "notes-analyst"
  group = aws_iam_group.team["analysts"].name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid      = "ReadNotes"
      Effect   = "Allow"
      Action   = ["dynamodb:GetItem", "dynamodb:Scan"]
      Resource = aws_dynamodb_table.notes.arn
    }]
  })
}

# Auditors: see how everything is configured and read the audit trail, change nothing
resource "aws_iam_group_policy_attachment" "auditors" {
  group      = aws_iam_group.team["auditors"].name
  policy_arn = "arn:aws:iam::aws:policy/SecurityAudit"
}

# One practice user per group, with no password and no keys: they exist only to test policies
resource "aws_iam_user" "practice" {
  for_each = { dev = "developers", ana = "analysts", aud = "auditors" }
  name     = "practice-${each.key}"
}

resource "aws_iam_user_group_membership" "practice" {
  for_each = { dev = "developers", ana = "analysts", aud = "auditors" }
  user     = aws_iam_user.practice[each.key].name
  groups   = [aws_iam_group.team[each.value].name]
}
