output "site_url" {
  value = "https://${aws_cloudfront_distribution.site.domain_name}"
}

output "api_url" {
  value = aws_apigatewayv2_api.notes.api_endpoint
}

output "files_bucket" {
  value = aws_s3_bucket.files.bucket
}

output "lab_ip" {
  value = aws_instance.lab.public_ip
}
