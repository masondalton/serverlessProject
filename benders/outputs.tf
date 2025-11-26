output "s3_website_url" {
  description = "Public URL of the S3 static website"
  value       = aws_s3_bucket_website_configuration.frontend.website_endpoint
}

output "api_base_url" {
  description = "Base URL for the API Gateway prod stage"
  value       = "https://${aws_api_gateway_rest_api.api.id}.execute-api.${var.region}.amazonaws.com/${aws_api_gateway_stage.prod.stage_name}"
}

output "benders_endpoint" {
  description = "Full URL for GET /benders"
  value       = "${output.api_base_url.value}/benders"
}
