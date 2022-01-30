#================================================#
# ALB Security Group
#================================================#
resource "aws_security_group" "alb" {
  vpc_id      = data.terraform_remote_state.network.outputs.network_vpc_id
  name        = "${var.sys}-${terraform.workspace}-alb-sg"
  description = "ALB"
  tags = {
    Name = "${var.sys}-${terraform.workspace}-alb-sg"
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

#================================================#
# Application Security Group
#================================================#
resource "aws_security_group" "app" {
  vpc_id      = data.terraform_remote_state.network.outputs.network_vpc_id
  name        = "${var.sys}-${terraform.workspace}-app-sg"
  description = "Application"
  tags = {
    Name = "${var.sys}-${terraform.workspace}-app-sg"
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

#================================================#
# DB Security Group
#================================================#
resource "aws_security_group" "db" {
  vpc_id      = data.terraform_remote_state.network.outputs.network_vpc_id
  name        = "${var.sys}-${terraform.workspace}-db-sg"
  description = "DB"
  tags = {
    Name = "${var.sys}-${terraform.workspace}-db-sg"
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
