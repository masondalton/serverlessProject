variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "region" {
  type = string
}

variable "domain_prefix" {
  type = string
}

variable "callback_urls" {
  type = list(string)
}

variable "logout_urls" {
  type = list(string)
}

variable "allowed_oauth_scopes_list" {
  type = list(string)
}

variable "allowed_oauth_flows_list" {
  type = list(string)
}

variable "supported_identity_providers" {
  type = list(string)
}

variable "create_admin_user" {
  type    = bool
  default = false
}

variable "admin_username" {
  type    = string
  default = "admin"
}

variable "admin_email" {
  type    = string
  default = "admin@example.com"
}

variable "admin_temp_password" {
  type    = string
  default = "ChangeMe123!"
}

resource "aws_cognito_user_pool" "this" {
  name = "${var.project_name}-${var.environment}-user-pool"

  auto_verified_attributes = ["email"]

  schema {
    name                = "email"
    required            = true
    attribute_data_type = "String"
    mutable             = true
  }
}

resource "aws_cognito_user_pool_client" "this" {
  name         = "${var.project_name}-${var.environment}-app-client"
  user_pool_id = aws_cognito_user_pool.this.id

  allowed_oauth_flows_user_pool_client = true

  allowed_oauth_scopes = var.allowed_oauth_scopes_list
  allowed_oauth_flows  = var.allowed_oauth_flows_list

  supported_identity_providers = var.supported_identity_providers

  callback_urls = var.callback_urls
  logout_urls   = var.logout_urls
}

resource "aws_cognito_user_pool_domain" "this" {
  domain       = var.domain_prefix
  user_pool_id = aws_cognito_user_pool.this.id
}

resource "aws_cognito_user" "admin" {
  count = var.create_admin_user ? 1 : 0

  user_pool_id = aws_cognito_user_pool.this.id
  username     = var.admin_username
  enabled      = true

  temporary_password = var.admin_temp_password
  message_action     = "SUPPRESS" # avoid sending email/SMS from Terraform

  attributes = {
    email          = var.admin_email
    email_verified = "true"
  }
}
