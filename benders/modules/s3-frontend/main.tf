
variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "frontend_path" {
  type = string
}

resource "aws_s3_bucket" "frontend" {
  bucket = "${var.project_name}-${var.environment}-frontend"
}

resource "aws_s3_bucket_website_configuration" "frontend" {
  bucket = aws_s3_bucket.frontend.id

  index_document {
    suffix = "index.html"
  }
}

resource "aws_s3_bucket_public_access_block" "frontend" {
  bucket = aws_s3_bucket.frontend.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "frontend" {
  bucket = aws_s3_bucket.frontend.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = "*"
        Action   = ["s3:GetObject"]
        Resource = "${aws_s3_bucket.frontend.arn}/*"
      }
    ]
  })
}

locals {
  frontend_files = fileset(var.frontend_path, "**/*")
}

resource "aws_s3_object" "frontend_files" {
  for_each = { for f in local.frontend_files : f => f }

  bucket = aws_s3_bucket.frontend.id
  key    = each.key
  source = "${var.frontend_path}/${each.key}"

  content_type = (
    can(regex("\\.html$", each.key)) ? "text/html" :
    can(regex("\\.css$", each.key))  ? "text/css"  :
    can(regex("\\.js$", each.key))   ? "application/javascript" :
    "binary/octet-stream"
  )
}
