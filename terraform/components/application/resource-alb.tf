#================================================#
# Certificate
#================================================#
resource "aws_acm_certificate" "this" {
  domain_name       = var.domain_name
  validation_method = "DNS"
  tags = {
    Name = "${var.sys}-${terraform.workspace}-cert"
  }
}

resource "aws_route53_record" "cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.this.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.this.zone_id
}

resource "aws_acm_certificate_validation" "this" {
  certificate_arn         = aws_acm_certificate.this.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
}

#================================================#
# Domain
#================================================#
resource "aws_route53_record" "this" {
  zone_id = data.aws_route53_zone.this.zone_id
  name    = var.domain_name
  type    = "A"

  alias {
    name                   = aws_lb.this.dns_name
    zone_id                = aws_lb.this.zone_id
    evaluate_target_health = true
  }
}

#================================================#
# ALB
#================================================#
resource "aws_lb" "this" {
  subnets = [
    data.terraform_remote_state.network.outputs.network_subnet_public_1_id,
    data.terraform_remote_state.network.outputs.network_subnet_public_2_id,
    data.terraform_remote_state.network.outputs.network_subnet_public_3_id,
  ]
  name = "${var.sys}-${terraform.workspace}-alb"
  security_groups = [
    data.terraform_remote_state.security.outputs.security_sg_alb_id,
  ]
  tags = {
    Name = "${var.sys}-${terraform.workspace}-alb"
  }
}

resource "aws_lb_target_group" "this" {
  vpc_id   = data.terraform_remote_state.network.outputs.network_vpc_id
  port     = 80
  protocol = "HTTP"
  name     = "${var.sys}-${terraform.workspace}-tg"
  tags = {
    Name = "${var.sys}-${terraform.workspace}-tg"
  }
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.this.arn
  port              = 443
  protocol          = "HTTPS"
  certificate_arn   = aws_acm_certificate.this.arn
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }
  tags = {
    Name = "${var.sys}-${terraform.workspace}-https-listener"
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.this.arn
  port              = 80
  default_action {
    type = "redirect"
    redirect {
      protocol    = "HTTPS"
      port        = "443"
      status_code = "HTTP_301"
    }
  }
  tags = {
    Name = "${var.sys}-${terraform.workspace}-http-listener"
  }
}
