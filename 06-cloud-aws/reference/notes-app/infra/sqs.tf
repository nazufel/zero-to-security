resource "aws_sqs_queue" "events" {
  name                      = "${var.name}-events"
  message_retention_seconds = 86400
  sqs_managed_sse_enabled   = true
}

data "archive_file" "audit" {
  type        = "zip"
  source_file = "${path.module}/../lambda/audit.py"
  output_path = "${path.module}/build/audit.zip"
}

resource "aws_iam_role" "audit" {
  name = "${var.name}-audit"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "audit_logs" {
  role       = aws_iam_role.audit.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy" "audit" {
  name = "read-events-queue"
  role = aws_iam_role.audit.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["sqs:ReceiveMessage", "sqs:DeleteMessage", "sqs:GetQueueAttributes"]
      Resource = aws_sqs_queue.events.arn
    }]
  })
}

resource "aws_cloudwatch_log_group" "audit" {
  name              = "/aws/lambda/${var.name}-audit"
  retention_in_days = 14
}

resource "aws_lambda_function" "audit" {
  function_name    = "${var.name}-audit"
  role             = aws_iam_role.audit.arn
  runtime          = "python3.14"
  handler          = "audit.handler"
  filename         = data.archive_file.audit.output_path
  source_code_hash = data.archive_file.audit.output_base64sha256

  depends_on = [aws_cloudwatch_log_group.audit]
}

resource "aws_lambda_event_source_mapping" "audit" {
  event_source_arn = aws_sqs_queue.events.arn
  function_name    = aws_lambda_function.audit.arn
  batch_size       = 10
}
