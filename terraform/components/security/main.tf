terraform {
  backend "s3" {
    region               = "ap-northeast-1"
    profile              = "terraform"
    bucket               = "tanavel-tf-state"
    workspace_key_prefix = "security"
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

#================================================#
# Service Linked Role
#================================================#
resource "aws_iam_service_linked_role" "ecs" {
  aws_service_name = "ecs.amazonaws.com"
}

resource "aws_iam_service_linked_role" "rds" {
  aws_service_name = "rds.amazonaws.com"
}

resource "aws_iam_service_linked_role" "lb" {
  aws_service_name = "elasticloadbalancing.amazonaws.com"
}

resource "aws_iam_service_linked_role" "asg" {
  aws_service_name = "autoscaling.amazonaws.com"
}

#================================================#
# Security Group
#================================================#
resource "aws_security_group" "alb" {
  vpc_id      = data.terraform_remote_state.network.outputs.network_vpc_id
  name        = "tanavel-prd-alb-sg"
  description = "ALB"
  tags = {
    Name = "tanavel-prd-alb-sg"
    Env  = "prd"
    Sys  = "tanavel"
  }
}

resource "aws_security_group_rule" "alb_ingress_https" {
  type              = "ingress"
  from_port         = "443"
  to_port           = "443"
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.alb.id
}

resource "aws_security_group_rule" "alb_ingress_http" {
  type              = "ingress"
  from_port         = "80"
  to_port           = "80"
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.alb.id
}

resource "aws_security_group_rule" "alb_egress_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.alb.id
}

resource "aws_security_group" "app" {
  vpc_id      = data.terraform_remote_state.network.outputs.network_vpc_id
  name        = "tanavel-prd-app-sg"
  description = "App"
  tags = {
    Name = "tanavel-prd-alb-sg"
    Env  = "prd"
    Sys  = "tanavel"
  }
}

resource "aws_security_group_rule" "app_ingress_http" {
  type                     = "ingress"
  from_port                = "32768"
  to_port                  = "61000"
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.alb.id
  security_group_id        = aws_security_group.app.id
}

resource "aws_security_group_rule" "app_egress_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.app.id
}

resource "aws_security_group" "db" {
  vpc_id      = data.terraform_remote_state.network.outputs.network_vpc_id
  name        = "tanavel-prd-db-sg"
  description = "DB"
  tags = {
    Name = "tanavel-prd-alb-sg"
    Env  = "prd"
    Sys  = "tanavel"
  }
}

resource "aws_security_group_rule" "db_ingress_dbport" {
  type                     = "ingress"
  from_port                = "3306"
  to_port                  = "3306"
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.app.id
  security_group_id        = aws_security_group.db.id
}

resource "aws_security_group_rule" "db_exgress_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.db.id
}
