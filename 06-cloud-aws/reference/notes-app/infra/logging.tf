# Module 9: an audit trail you keep, with data events, and alarms that page you.

variable "alert_email" {
  description = "Where alarms are sent. You'll get a confirmation email to accept."
  type        = string
  default     = "you@example.com"
}

# --- CloudTrail: every API call, kept in a bucket, checked for tampering ---

resource "aws_s3_bucket" "trail" {
  bucket_prefix = "${var.name}-trail-"
  force_destroy = true # lab only
}

resource "aws_s3_bucket_public_access_block" "trail" {
  bucket = aws_s3_bucket.trail.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "trail" {
  bucket = aws_s3_bucket.trail.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_policy" "trail" {
  bucket = aws_s3_bucket.trail.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "CloudTrailCheckAcl"
        Effect    = "Allow"
        Principal = { Service = "cloudtrail.amazonaws.com" }
        Action    = "s3:GetBucketAcl"
        Resource  = aws_s3_bucket.trail.arn
        Condition = { StringEquals = { "aws:SourceArn" = "arn:aws:cloudtrail:${var.region}:${data.aws_caller_identity.current.account_id}:trail/${var.name}-trail" } }
      },
      {
        Sid       = "CloudTrailWrite"
        Effect    = "Allow"
        Principal = { Service = "cloudtrail.amazonaws.com" }
        Action    = "s3:PutObject"
        Resource  = "${aws_s3_bucket.trail.arn}/AWSLogs/${data.aws_caller_identity.current.account_id}/*"
        Condition = {
          StringEquals = {
            "s3:x-amz-acl"  = "bucket-owner-full-control"
            "aws:SourceArn" = "arn:aws:cloudtrail:${var.region}:${data.aws_caller_identity.current.account_id}:trail/${var.name}-trail"
          }
        }
      },
      {
        Sid       = "DenyUnencryptedTransport"
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:*"
        Resource  = [aws_s3_bucket.trail.arn, "${aws_s3_bucket.trail.arn}/*"]
        Condition = { Bool = { "aws:SecureTransport" = "false" } }
      },
    ]
  })
}

resource "aws_cloudwatch_log_group" "trail" {
  name              = "/aws/cloudtrail/${var.name}"
  retention_in_days = 14
}

resource "aws_iam_role" "trail" {
  name = "${var.name}-cloudtrail-logs"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "cloudtrail.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "trail" {
  name = "write-trail-logs"
  role = aws_iam_role.trail.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["logs:CreateLogStream", "logs:PutLogEvents"]
      Resource = "${aws_cloudwatch_log_group.trail.arn}:*"
    }]
  })
}

resource "aws_cloudtrail" "main" {
  name                       = "${var.name}-trail"
  s3_bucket_name             = aws_s3_bucket.trail.id
  enable_log_file_validation = true
  is_multi_region_trail      = true # attackers love the regions you never look at
  cloud_watch_logs_group_arn = "${aws_cloudwatch_log_group.trail.arn}:*"
  cloud_watch_logs_role_arn  = aws_iam_role.trail.arn

  # Management events (the default), plus data events for the notes table and files bucket
  advanced_event_selector {
    name = "Management events"
    field_selector {
      field  = "eventCategory"
      equals = ["Management"]
    }
  }

  advanced_event_selector {
    name = "Notes table reads and writes"
    field_selector {
      field  = "eventCategory"
      equals = ["Data"]
    }
    field_selector {
      field  = "resources.type"
      equals = ["AWS::DynamoDB::Table"]
    }
    field_selector {
      field  = "resources.ARN"
      equals = [aws_dynamodb_table.notes.arn]
    }
  }

  advanced_event_selector {
    name = "Files bucket object access"
    field_selector {
      field  = "eventCategory"
      equals = ["Data"]
    }
    field_selector {
      field  = "resources.type"
      equals = ["AWS::S3::Object"]
    }
    field_selector {
      field       = "resources.ARN"
      starts_with = ["${aws_s3_bucket.files.arn}/"]
    }
  }

  depends_on = [aws_s3_bucket_policy.trail, aws_iam_role_policy.trail]
}

# --- Alerts: email when something looks wrong ---

resource "aws_sns_topic" "alerts" {
  name = "${var.name}-alerts"
}

resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = var.alert_email
}

# Alarm 1: a burst of access-denied errors anywhere in the account
resource "aws_cloudwatch_log_metric_filter" "access_denied" {
  name           = "access-denied"
  log_group_name = aws_cloudwatch_log_group.trail.name
  pattern        = "{ ($.errorCode = \"AccessDenied*\") || ($.errorCode = \"*UnauthorizedOperation\") }"

  metric_transformation {
    name      = "AccessDeniedCount"
    namespace = "NotesApp/Security"
    value     = "1"
  }
}

resource "aws_cloudwatch_metric_alarm" "access_denied" {
  alarm_name          = "${var.name}-access-denied-burst"
  alarm_description   = "5 or more access-denied errors in 5 minutes: someone may be probing with stolen credentials"
  namespace           = "NotesApp/Security"
  metric_name         = "AccessDeniedCount"
  statistic           = "Sum"
  period              = 300
  evaluation_periods  = 1
  threshold           = 5
  comparison_operator = "GreaterThanOrEqualToThreshold"
  treat_missing_data  = "notBreaching"
  alarm_actions       = [aws_sns_topic.alerts.arn]
}

# Alarm 2: the notes API is throwing errors
resource "aws_cloudwatch_metric_alarm" "api_errors" {
  alarm_name          = "${var.name}-api-errors"
  alarm_description   = "The notes API function is failing"
  namespace           = "AWS/Lambda"
  metric_name         = "Errors"
  dimensions          = { FunctionName = aws_lambda_function.notes.function_name }
  statistic           = "Sum"
  period              = 300
  evaluation_periods  = 1
  threshold           = 3
  comparison_operator = "GreaterThanOrEqualToThreshold"
  treat_missing_data  = "notBreaching"
  alarm_actions       = [aws_sns_topic.alerts.arn]
}

# --- API Gateway access logs: one line per request ---

resource "aws_cloudwatch_log_group" "api_access" {
  name              = "/aws/apigateway/${var.name}-api"
  retention_in_days = 14
}

# --- VPC flow logs: every connection attempt to the lab network ---

resource "aws_cloudwatch_log_group" "flow" {
  name              = "/aws/vpc/${var.name}-flow"
  retention_in_days = 14
}

resource "aws_iam_role" "flow" {
  name = "${var.name}-flow-logs"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "vpc-flow-logs.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "flow" {
  name = "write-flow-logs"
  role = aws_iam_role.flow.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["logs:CreateLogStream", "logs:PutLogEvents", "logs:DescribeLogStreams"]
      Resource = "${aws_cloudwatch_log_group.flow.arn}:*"
    }]
  })
}

resource "aws_flow_log" "lab" {
  vpc_id          = aws_vpc.lab.id
  traffic_type    = "ALL"
  log_destination = aws_cloudwatch_log_group.flow.arn
  iam_role_arn    = aws_iam_role.flow.arn
}
