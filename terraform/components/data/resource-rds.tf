#================================================#
# Parameter Store
#================================================#
resource "aws_ssm_parameter" "db_username" {
  name  = "/${var.sys}/${terraform.workspace}/db/username"
  type  = "SecureString"
  value = var.db_username

  tags = {
    Name = "${var.sys}-${terraform.workspace}-db-username"
  }

  lifecycle {
    ignore_changes = [
      value,
    ]
  }
}

resource "aws_ssm_parameter" "db_password" {
  name  = "/${var.sys}/${terraform.workspace}/db/password"
  type  = "SecureString"
  value = var.db_password

  tags = {
    Name = "${var.sys}-${terraform.workspace}-db-password"
  }

  lifecycle {
    ignore_changes = [
      value,
    ]
  }
}

#================================================#
# RDS
#================================================#
resource "aws_db_instance" "this" {
  instance_class      = "db.t2.micro"
  allocated_storage   = 20
  engine              = "mysql"
  username            = var.db_username
  password            = var.db_password
  engine_version      = "8.0.20"
  skip_final_snapshot = true
  apply_immediately   = true

  tags = {
    Name = "${var.sys}-${terraform.workspace}-db-1"
  }

  lifecycle {
    ignore_changes = [
      username,
      password,
    ]
  }
}
