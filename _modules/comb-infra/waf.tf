resource "aws_wafv2_web_acl" "this" {
  name        = "${var.name_prefix}-app"
  description = "App WAFv2 Web ACL"
  scope       = "REGIONAL"

  default_action {
    allow {}
  }

  rule {
    name     = "AWS-AWSManagedRulesCommonRuleSet"
    priority = 1

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"

        rule_action_override {
          name = "SizeRestrictions_BODY"
          action_to_use {
            allow {}
          }
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "CommonRuleSet"
      sampled_requests_enabled   = true
    }
  }

  tags = var.tags

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "${var.name_prefix}-app-waf"
    sampled_requests_enabled   = true
  }
}

output "wafv2_arn" {
  description = "The ARN of the WAFv2 Web ACL"
  value       = aws_wafv2_web_acl.this.arn
}

output "wafv2_id" {
  description = "The ID of the WAFv2 Web ACL"
  value       = aws_wafv2_web_acl.this.id
}
