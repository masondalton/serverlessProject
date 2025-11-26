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

resource "local_file" "frontend_config" {
  content = <<EOF
window.APP_CONFIG = {
  API_BASE: "${module.lambda_api.api_base_url}"
};
EOF

  filename = "${path.module}/../frontend/js/config.js"
}


