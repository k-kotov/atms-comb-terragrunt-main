module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "9.13.0"

  name = "${var.name_prefix}-app"

  vpc_id  = var.vpc_id
  subnets = var.private_subnet_ids

  # For example only
  enable_deletion_protection = false

  associate_web_acl = true
  web_acl_arn       = aws_wafv2_web_acl.this.arn

  # Security Group
  security_group_ingress_rules = {
    all_http = {
      from_port   = 80
      to_port     = 82
      ip_protocol = "tcp"
      description = "HTTP web traffic"
      cidr_ipv4   = "0.0.0.0/0"
    }
    all_https = {
      from_port   = 443
      to_port     = 445
      ip_protocol = "tcp"
      description = "HTTPS web traffic"
      cidr_ipv4   = "0.0.0.0/0"
    }
  }
  security_group_egress_rules = {
    all = {
      ip_protocol = "-1"
      cidr_ipv4   = "0.0.0.0/0"
    }
  }

  access_logs = {
    bucket = module.log_bucket.s3_bucket_id
    prefix = "access-logs"
  }

  connection_logs = {
    bucket  = module.log_bucket.s3_bucket_id
    enabled = true
    prefix  = "connection-logs"
  }

  client_keep_alive = 7200

  listeners = {
    redirect = {
      port     = 80
      protocol = "HTTP"

      redirect = {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }

    https = {
      port            = 443
      protocol        = "HTTPS"
      certificate_arn = module.certificate.acm_certificate_arn

      forward = {
        target_group_key = "app"
      }
    }
  }

  target_groups = {
    app = {
      name_prefix                   = "app"
      protocol                      = "HTTP"
      port                          = 80
      target_type                   = "instance"
      load_balancing_algorithm_type = "round_robin"
      create_attachment             = true
      target_id                     = module.app.id

      health_check = {
        enabled  = true
        interval = 30
        path     = "/app/index.html"
        protocol = "HTTP"
        matcher  = "200-499"
      }
    }
  }

  # Route53 Record(s)
  route53_records = {
    A = {
      name    = var.alb_route53_record_name
      type    = "A"
      zone_id = var.route53_zone_id
    }
  }

  tags = var.tags
}

module "certificate" {
  source  = "terraform-aws-modules/acm/aws"
  version = "5.1.1"

  domain_name = var.alb_route53_record_name
  zone_id     = var.route53_zone_id

  validation_method = "DNS"

  wait_for_validation = true

  tags = var.tags
}

module "log_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "3.14.0"

  bucket_prefix = "${var.name_prefix}-"
  acl           = "log-delivery-write"

  force_destroy = true

  control_object_ownership = true
  object_ownership         = "ObjectWriter"

  attach_elb_log_delivery_policy = true # Required for ALB logs
  attach_lb_log_delivery_policy  = true # Required for ALB/NLB logs

  attach_deny_insecure_transport_policy = true
  attach_require_latest_tls_policy      = true

  tags = var.tags
}
