#================================================#
# ECR
#================================================#
resource "aws_ecr_repository" "web" {
  name = "${var.sys}-${terraform.workspace}-web-repo"
  tags = {
    Name = "${var.sys}-${terraform.workspace}-web-repo"
  }
}

resource "aws_ecr_repository" "app" {
  name = "${var.sys}-${terraform.workspace}-app-repo"
  tags = {
    Name = "${var.sys}-${terraform.workspace}-app-repo"
  }
}
