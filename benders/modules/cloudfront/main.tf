variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "s3_bucket_domain_name" {
  type        = string
  description = "S3 bucket regional domain name for origin"
}

variable "s3_website_endpoint" {
  type        = string
  description = "S3 static website endpoint"
}

variable "price_class" {
  type    = string
  default = "PriceClass_100"
}

variable "custom_domain_names" {
  type        = list(string)
  default     = []
  description = "Custom domain aliases for CloudFront (optional, requires ACM cert in us-east-1)"
}

variable "acm_certificate_arn" {
  type        = string
  default     = ""
  description = "ACM certificate ARN in us-east-1 for the custom domain aliases (required if custom_domain_names set)"
}

variable "hosted_zone_id" {
  type        = string
  default     = ""
  description = "Route53 hosted zone ID for creating alias records to CloudFront (optional)"
}

locals {
  use_custom_domain = length(var.custom_domain_names) > 0 && var.acm_certificate_arn != ""
}

resource "aws_cloudfront_distribution" "this" {
  enabled             = true
  comment             = "${var.project_name}-${var.environment}-frontend"
  price_class         = var.price_class
  default_root_object = "index.html"

  origin {
    domain_name = var.s3_bucket_domain_name
    origin_id   = "s3-frontend"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "s3-frontend"

    viewer_protocol_policy = "redirect-to-https"

    forwarded_values {
      query_string = true
      cookies {
        forward = "none"
      }
    }
  }

  aliases = local.use_custom_domain ? var.custom_domain_names : []

  viewer_certificate {
    acm_certificate_arn            = local.use_custom_domain ? var.acm_certificate_arn : null
    cloudfront_default_certificate = local.use_custom_domain ? false : true
    minimum_protocol_version       = local.use_custom_domain ? "TLSv1.2_2021" : null
    ssl_support_method             = local.use_custom_domain ? "sni-only" : null
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
}

resource "aws_route53_record" "this" {
  for_each = local.use_custom_domain && var.hosted_zone_id != "" ? toset(var.custom_domain_names) : []

  name    = each.value
  type    = "A"
  zone_id = var.hosted_zone_id

  alias {
    name                   = aws_cloudfront_distribution.this.domain_name
    zone_id                = aws_cloudfront_distribution.this.hosted_zone_id
    evaluate_target_health = false
  }
}
