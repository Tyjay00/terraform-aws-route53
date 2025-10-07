variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "domain_name" {
  description = "Domain name for the website"
  type        = string
  default     = ""
}

variable "create_hosted_zone" {
  description = "Whether to create a new hosted zone"
  type        = bool
  default     = true
}

variable "hosted_zone_id" {
  description = "Existing hosted zone ID (used when create_hosted_zone is false)"
  type        = string
  default     = ""
}

variable "cloudfront_domain_name" {
  description = "CloudFront distribution domain name"
  type        = string
}

variable "cloudfront_hosted_zone_id" {
  description = "CloudFront hosted zone ID"
  type        = string
}

variable "enable_ipv6" {
  description = "Whether to enable IPv6 support"
  type        = bool
  default     = true
}

variable "enable_health_check" {
  description = "Whether to enable Route53 health check"
  type        = bool
  default     = false
}

variable "sns_topic_arn" {
  description = "SNS topic ARN for health check notifications"
  type        = string
  default     = ""
}