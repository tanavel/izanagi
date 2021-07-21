terraform {
  backend "s3" {
    region               = "ap-northeast-1"
    profile              = "terraform"
    bucket               = "tanavel-tf-state"
    workspace_key_prefix = "application"
    key                  = "terraform.tfstate"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.27"
    }
  }

  required_version = ">= 0.14.9"
}

provider "aws" {
  profile = "terraform"
  region  = "ap-northeast-1"
}

data "terraform_remote_state" "security" {
  backend   = "s3"
  workspace = "prd"
  config = {
    region               = "ap-northeast-1"
    profile              = "terraform"
    bucket               = "tanavel-tf-state"
    workspace_key_prefix = "security"
    key                  = "terraform.tfstate"
  }
}

data "terraform_remote_state" "network" {
  backend   = "s3"
  workspace = "prd"
  config = {
    region               = "ap-northeast-1"
    profile              = "terraform"
    bucket               = "tanavel-tf-state"
    workspace_key_prefix = "network"
    key                  = "terraform.tfstate"
  }
}

data "aws_route53_zone" "this" {
  name = "tanavel.net"
}

#================================================#
# Certificate
#================================================#
resource "aws_acm_certificate" "this" {
  # Required
  domain_name = "tanavel.net"
  validation_method = "DNS"
  # Optional
  tags = {
    Name = "tanavel-prd-cert"
    Env  = "prd"
    Sys  = "tanavel"
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
  name = "tanavel.net"
  type = "A"

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
  # Required
  subnets = [
    data.terraform_remote_state.network.outputs.network_subnet_public_1_id,
    data.terraform_remote_state.network.outputs.network_subnet_public_2_id,
    data.terraform_remote_state.network.outputs.network_subnet_public_3_id,
  ]
  # Optional
  name = "tanavel-prd-alb"
  security_groups = [
    data.terraform_remote_state.security.outputs.security_sg_alb_id,
  ]
  tags = {
    Name = "tanavel-prd-alb"
    Env  = "prd"
    Sys  = "tanavel"
  }
}

resource "aws_lb_target_group" "this" {
  # Required
  vpc_id = data.terraform_remote_state.network.outputs.network_vpc_id
  port = 80
  protocol = "HTTP"

  # Optional
  name = "tanavel-prd-tg"
  tags = {
    Name = "tanavel-prd-tg"
    Env  = "prd"
    Sys  = "tanavel"
  }
}

resource "aws_lb_listener" "https" {
  # Required
  load_balancer_arn = aws_lb.this.arn
  port = 443
  # Optional
  protocol = "HTTPS"
  certificate_arn = aws_acm_certificate.this.arn
  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }
}

resource "aws_lb_listener" "http" {
  # Required
  load_balancer_arn = aws_lb.this.arn
  port = 80
  default_action {
    type = "redirect"
    redirect {
      protocol = "HTTPS"
      port = "443"
      status_code = "HTTP_301"
    }
  }
  # Optional
  tags = {
    Name = "tanavel-prd-alb-listener"
    Env  = "prd"
    Sys  = "tanavel"
  }
}

#================================================#
# EC2 Instance
#================================================#
resource "aws_launch_template" "this" {
  # Optional
  name                   = "tanavel-prd-lt"
  description            = "Basic instance for ECS launch type EC2"
  image_id               = "ami-0ffb5f4e03c892bc5"
  instance_type          = "t2.micro"
  update_default_version = true
  user_data = base64encode(
    templatefile(
      "${path.module}/user_data.sh",
      {
        ecs_cluster_name = aws_ecs_cluster.this.name
      }
    )
  )
  vpc_security_group_ids = [
    data.terraform_remote_state.security.outputs.security_sg_app_id,
  ]
  iam_instance_profile {
    name = data.terraform_remote_state.security.outputs.security_iam_role_ecs_instance_profile_name
  }
  tags = {
    Name = "tanavel-prd-lt"
    Env  = "prd"
    Sys  = "tanavel"
  }
}

resource "aws_autoscaling_group" "this" {
  # Required
  max_size = 1
  min_size = 1
  launch_template {
    id      = aws_launch_template.this.id
    version = aws_launch_template.this.latest_version
  }
  vpc_zone_identifier = [
    data.terraform_remote_state.network.outputs.network_subnet_public_1_id,
    data.terraform_remote_state.network.outputs.network_subnet_public_2_id,
    data.terraform_remote_state.network.outputs.network_subnet_public_3_id,
  ]
  # Optional
  name     = "tanavel-prd-asg"
  wait_for_capacity_timeout = 0
  force_delete = true
  instance_refresh {
    strategy = "Rolling"
    triggers = [
      "tags",
      "vpc_zone_identifier",
    ]
  }
  tags = [
    {
      "key" = "Name"
      "value" = "tanavel-prd-ecs-instance"
      "propagate_at_launch" = true
    },
    {
      "key" = "Env"
      "value" = "prd"
      "propagate_at_launch" = true
    },
    {
      "key" = "Sys"
      "value" = "tanavel"
      "propagate_at_launch" = true
    },
  ]
}

#================================================#
# ECS
#================================================#
resource "aws_ecs_cluster" "this" {
  # Required
  name = "tanavel-prd-app"
  # Optional
  tags = {
    Name = "tanavel-prd-app"
    Env  = "prd"
    Sys  = "tanavel"
  }
}

resource "aws_ecs_service" "this" {
  # Required
  cluster = aws_ecs_cluster.this.id
  name = "tanavel-prd-app"
  task_definition = aws_ecs_task_definition.this.arn
  # Optional
  desired_count = 1
  iam_role = data.terraform_remote_state.security.outputs.security_service_role_ecs_arn
  load_balancer {
    # Required
    target_group_arn = aws_lb_target_group.this.arn
    container_name = "web"
    container_port = "80"
  }
}

resource "aws_ecs_task_definition" "this" {
  # Required
  family = "tanavel-prd-app-task-definition"
  container_definitions = jsonencode([
    {
      name = "web"
      image = "nginx"
      # Memory指定しないと怒られるから書いたけど消したいね。1024だとコンテナ立ち上がらなかったから256にした
      memory = 256
      # Enable dynamic port mapping. Required if you want associate with ALB
      portMappings = [
        {
            containerPort = 80
            hostPort = 0
        }
      ]
    }
  ])
}
