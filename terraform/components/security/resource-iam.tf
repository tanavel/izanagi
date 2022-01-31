#================================================#
# IAM Role
#================================================#
resource "aws_iam_role" "ecs_instance" {
  name = "${var.sys}-${terraform.workspace}-ecs-instance-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "",
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      },
    ]
  })
  tags = {
    Name = "${var.sys}-${terraform.workspace}-ecs-instance-role"
  }
}

resource "aws_iam_instance_profile" "ecs_instance" {
  name = "${var.sys}-${terraform.workspace}-ecs-instance-role"
  role = aws_iam_role.ecs_instance.name
}

resource "aws_iam_role_policy_attachment" "ecs_instance_ssm" {
  role       = aws_iam_role.ecs_instance.id
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "ecs_instance_ecs" {
  role       = aws_iam_role.ecs_instance.id
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
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
