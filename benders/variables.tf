variable "project_name" {
  type        = string
  description = "Name prefix for all AWS resources"
  default     = "avatar-archive" # <-- customize this
}

variable "environment" {
  type        = string
  description = "Environment name (dev, prod, test)"
  default     = "dev" # <-- change to prod later if needed
}

variable "region" {
  type        = string
  description = "AWS region to deploy into"
  default     = "us-east-1" # <-- or us-east-1 if you prefer
}

variable "frontend_path" {
  type        = string
  description = "Path to frontend files"
  default     = "../frontend" # <-- keep unless you rename folders
}

variable "lambda_path" {
  type        = string
  description = "Path to lambda source code"
  default     = "../lambda" # <-- keep unless you rename folders
}

variable "cognito_domain_prefix" {
  type        = string
  description = "Prefix for the Cognito hosted UI domain (must be globally unique per region)"
  default     = "avatar-archive-dev" # <-- change to something unique per environment
}

variable "cognito_callback_urls" {
  type        = list(string)
  description = "Allowed Cognito callback URLs for the hosted UI redirect"
  default     = [] # If empty, will default to CloudFront/S3 endpoint
}

variable "cognito_logout_urls" {
  type        = list(string)
  description = "Allowed Cognito logout URLs for the hosted UI redirect"
  default     = [] # If empty, will default to CloudFront/S3 endpoint
}

variable "create_admin_user" {
  type        = bool
  description = "Set to true to seed an initial Cognito admin user"
  default     = false
}

variable "admin_username" {
  type        = string
  description = "Username for the seeded admin user"
  default     = "admin"
}

variable "admin_email" {
  type        = string
  description = "Email for the seeded admin user"
  default     = "admin@example.com"
}

variable "admin_temp_password" {
  type        = string
  description = "Temporary password for the seeded admin user (user must change on first login)"
  default     = "ChangeMe123!"
}

variable "cloudfront_price_class" {
  type        = string
  description = "CloudFront price class (e.g., PriceClass_100, PriceClass_200, PriceClass_All)"
  default     = "PriceClass_100"
}

variable "custom_domain_names" {
  type        = list(string)
  description = "Custom domain aliases for the frontend (optional, requires ACM cert in us-east-1)"
  default     = []
}

variable "custom_domain_hosted_zone_id" {
  type        = string
  description = "Route53 hosted zone ID for the custom domain aliases (optional)"
  default     = ""
}

variable "custom_domain_acm_cert_arn" {
  type        = string
  description = "ACM certificate ARN in us-east-1 for the custom domain aliases (required if custom_domain_names set)"
  default     = ""
}
