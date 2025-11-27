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

output "cognito_user_pool_id" {
  description = "Cognito User Pool ID"
  value       = module.cognito.user_pool_id
}

output "cognito_user_pool_client_id" {
  description = "Cognito App Client ID"
  value       = module.cognito.user_pool_client_id
}

output "cognito_hosted_ui_domain" {
  description = "Cognito hosted UI domain"
  value       = module.cognito.hosted_ui_domain
}

output "cloudfront_domain_name" {
  description = "CloudFront distribution domain name for the frontend"
  value       = module.cloudfront.cloudfront_domain_name
}

output "codepipeline_name" {
  description = "CodePipeline name (if enabled)"
  value       = var.enable_codepipeline ? module.codepipeline[0].pipeline_name : ""
}
