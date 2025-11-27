terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.0"
    }
  }
}

provider "aws" {
  region = var.region
}

module "dynamodb" {
  source       = "./modules/dynamodb"
  project_name = var.project_name
  environment  = var.environment
}

module "s3_frontend" {
  source        = "./modules/s3-frontend"
  project_name  = var.project_name
  environment   = var.environment
  frontend_path = "${path.module}/../frontend"
}

module "lambda_api" {
  source = "./modules/lambda-api"

  project_name      = var.project_name
  environment       = var.environment
  region            = var.region
  table_name        = module.dynamodb.table_name
  table_arn         = module.dynamodb.table_arn
  lambda_source_dir = "${path.module}/../lambda"
  user_pool_arn     = module.cognito.user_pool_arn
}

module "cognito" {
  source = "./modules/cognito"

  project_name  = var.project_name
  environment   = var.environment
  region        = var.region
  domain_prefix = var.cognito_domain_prefix

  callback_urls                = local.cognito_callback_urls
  logout_urls                  = local.cognito_logout_urls
  allowed_oauth_scopes_list    = ["email", "openid"]
  allowed_oauth_flows_list     = ["code"]
  supported_identity_providers = ["COGNITO"]
  create_admin_user            = var.create_admin_user
  admin_username               = var.admin_username
  admin_email                  = var.admin_email
  admin_temp_password          = var.admin_temp_password
}

module "cloudfront" {
  source = "./modules/cloudfront"

  project_name          = var.project_name
  environment           = var.environment
  s3_bucket_domain_name = module.s3_frontend.bucket_domain_name
  s3_website_endpoint   = module.s3_frontend.website_endpoint
  price_class           = var.cloudfront_price_class
  custom_domain_names   = var.custom_domain_names
  acm_certificate_arn   = var.custom_domain_acm_cert_arn
  hosted_zone_id        = var.custom_domain_hosted_zone_id
}

locals {
  frontend_base         = length(var.custom_domain_names) > 0 ? "https://${var.custom_domain_names[0]}" : "https://${module.cloudfront.cloudfront_domain_name}"
  cognito_callback_urls = length(var.cognito_callback_urls) > 0 ? var.cognito_callback_urls : ["${local.frontend_base}/admin.html"]
  cognito_logout_urls   = length(var.cognito_logout_urls) > 0 ? var.cognito_logout_urls : ["${local.frontend_base}/"]
}

module "codepipeline" {
  count = var.enable_codepipeline ? 1 : 0

  source = "./modules/codepipeline"

  project_name            = var.project_name
  environment             = var.environment
  frontend_bucket_name    = module.s3_frontend.bucket_name
  codestar_connection_arn = var.codestar_connection_arn
  repository_id           = "masondalton/serverlessProject"
  branch                  = "main"
}

resource "local_file" "frontend_config" {
  content = <<EOF
window.APP_CONFIG = {
  API_BASE: "${module.lambda_api.api_base_url}",
  COGNITO_DOMAIN: "${module.cognito.hosted_ui_domain}",
  COGNITO_USER_POOL_ID: "${module.cognito.user_pool_id}",
  COGNITO_CLIENT_ID: "${module.cognito.user_pool_client_id}"
};
EOF

  filename = "${path.module}/../frontend/js/config.js"
}
