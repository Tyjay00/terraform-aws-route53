# Route53 Hosted Zone
resource "aws_route53_zone" "main" {
  count = var.create_hosted_zone ? 1 : 0
  name  = var.domain_name

  tags = {
    Name        = "${var.project_name}-hosted-zone"
    Environment = var.environment
  }
}

# Route53 A record for CloudFront distribution
resource "aws_route53_record" "main" {
  count   = var.domain_name != "" ? 1 : 0
  zone_id = var.create_hosted_zone ? aws_route53_zone.main[0].zone_id : var.hosted_zone_id
  name    = var.domain_name
  type    = "A"

  alias {
    name                   = var.cloudfront_domain_name
    zone_id                = var.cloudfront_hosted_zone_id
    evaluate_target_health = false
  }
}

# Route53 AAAA record for IPv6 support
resource "aws_route53_record" "ipv6" {
  count   = var.domain_name != "" && var.enable_ipv6 ? 1 : 0
  zone_id = var.create_hosted_zone ? aws_route53_zone.main[0].zone_id : var.hosted_zone_id
  name    = var.domain_name
  type    = "AAAA"

  alias {
    name                   = var.cloudfront_domain_name
    zone_id                = var.cloudfront_hosted_zone_id
    evaluate_target_health = false
  }
}

# Route53 health check
resource "aws_route53_health_check" "main" {
  count                           = var.enable_health_check ? 1 : 0
  fqdn                           = var.domain_name
  port                           = 443
  type                           = "HTTPS"
  resource_path                  = "/"
  failure_threshold              = "3"
  request_interval               = "30"
  cloudwatch_alarm_region        = var.aws_region
  cloudwatch_alarm_name          = "${var.project_name}-health-check-alarm"
  insufficient_data_health_status = "Failure"

  tags = {
    Name        = "${var.project_name}-health-check"
    Environment = var.environment
  }
}

# CloudWatch alarm for health check
resource "aws_cloudwatch_metric_alarm" "health_check" {
  count = var.enable_health_check ? 1 : 0

  alarm_name          = "${var.project_name}-health-check-alarm"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "HealthCheckStatus"
  namespace           = "AWS/Route53"
  period              = "60"
  statistic           = "Minimum"
  threshold           = "1"
  alarm_description   = "This metric monitors health check status"
  alarm_actions       = var.sns_topic_arn != "" ? [var.sns_topic_arn] : []

  dimensions = {
    HealthCheckId = aws_route53_health_check.main[0].id
  }

  tags = {
    Name        = "${var.project_name}-health-check-alarm"
    Environment = var.environment
  }
}