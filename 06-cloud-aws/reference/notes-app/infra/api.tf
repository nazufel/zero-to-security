resource "aws_apigatewayv2_api" "notes" {
  name          = "${var.name}-api"
  protocol_type = "HTTP"

  cors_configuration {
    allow_origins = ["https://${aws_cloudfront_distribution.site.domain_name}"]
    allow_methods = ["GET", "POST"]
    allow_headers = ["content-type"]
  }
}

resource "aws_apigatewayv2_integration" "notes" {
  api_id                 = aws_apigatewayv2_api.notes.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.notes.invoke_arn
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "notes" {
  for_each = toset(["GET /notes", "POST /notes", "DELETE /notes/{id}"])

  api_id    = aws_apigatewayv2_api.notes.id
  route_key = each.value
  target    = "integrations/${aws_apigatewayv2_integration.notes.id}"
}

resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.notes.id
  name        = "$default"
  auto_deploy = true

  default_route_settings {
    throttling_burst_limit = 10
    throttling_rate_limit  = 5
  }
}

resource "aws_lambda_permission" "api" {
  statement_id  = "AllowApiGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.notes.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.notes.execution_arn}/*/*"
}
