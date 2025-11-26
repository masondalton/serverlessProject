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

