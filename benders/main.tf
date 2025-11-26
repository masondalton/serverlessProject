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
}

module "cognito" {
  source                       = "./modules/cognito"
  project_name                 = var.project_name
  environment                  = var.environment
  domain_prefix                = var.cognito_domain_prefix
  callback_urls                = ["http://localhost:3000/admin.html"]
  logout_urls                  = ["http://localhost:3000/"]
  allowed_oauth_scopes         = ["email", "openid"]
  allowed_oauth_flows          = ["code"]
  supported_identity_providers = ["COGNITO"]
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

