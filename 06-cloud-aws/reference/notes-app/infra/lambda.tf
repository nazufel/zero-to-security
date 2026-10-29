data "archive_file" "notes" {
  type        = "zip"
  source_file = "${path.module}/../lambda/notes.py"
  output_path = "${path.module}/build/notes.zip"
}

resource "aws_iam_role" "notes" {
  name = "${var.name}-lambda"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}


resource "aws_iam_role_policy" "notes" {
  name = "notes-app-access"
  role = aws_iam_role.notes.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["dynamodb:PutItem", "dynamodb:DeleteItem", "dynamodb:Scan"]
        Resource = aws_dynamodb_table.notes.arn
      },
      {
        Effect   = "Allow"
        Action   = ["logs:CreateLogStream", "logs:PutLogEvents"]
        Resource = "${aws_cloudwatch_log_group.notes.arn}:*"
      },
      {
        Effect   = "Allow"
        Action   = "sqs:SendMessage"
        Resource = aws_sqs_queue.events.arn
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "notes_xray" {
  role       = aws_iam_role.notes.name
  policy_arn = "arn:aws:iam::aws:policy/AWSXRayDaemonWriteAccess"
}

resource "aws_cloudwatch_log_group" "notes" {
  name              = "/aws/lambda/${var.name}-api"
  retention_in_days = 14
}

resource "aws_lambda_function" "notes" {
  function_name    = "${var.name}-api"
  role             = aws_iam_role.notes.arn
  runtime          = "python3.14"
  handler          = "notes.handler"
  filename         = data.archive_file.notes.output_path
  source_code_hash = data.archive_file.notes.output_base64sha256
  timeout          = 10

  tracing_config {
    mode = "Active"
  }

  environment {
    variables = {
      TABLE_NAME = aws_dynamodb_table.notes.name
      QUEUE_URL  = aws_sqs_queue.events.url
    }
  }

  depends_on = [aws_cloudwatch_log_group.notes]
}
