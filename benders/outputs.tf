output "s3_website_url" {
  description = "Public URL of the S3 static website"
  value       = module.s3_frontend.website_endpoint
}

output "api_base_url" {
  description = "Base URL for the API Gateway prod stage"
  value       = module.lambda_api.api_base_url
}

output "benders_endpoint" {
  description = "Full URL for GET /benders"
  value       = module.lambda_api.benders_endpoint
}
