#================================================#
# EC2 Instance
#================================================#
resource "aws_launch_template" "this" {
  name                   = "${var.sys}-${terraform.workspace}-lt"
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
    Name = "${var.sys}-${terraform.workspace}-lt"
  }
}

resource "aws_autoscaling_group" "this" {
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
  name                      = "${var.sys}-${terraform.workspace}-asg"
  wait_for_capacity_timeout = 0
  force_delete              = true
  instance_refresh {
    strategy = "Rolling"
    triggers = [
      "tags",
      "vpc_zone_identifier",
    ]
  }
  tags = [
    {
      "key"                 = "Name"
      "value"               = "${var.sys}-${terraform.workspace}-ecs-instance"
      "propagate_at_launch" = true
    },
    {
      "key"                 = "Env"
      "value"               = terraform.workspace
      "propagate_at_launch" = true
    },
    {
      "key"                 = "Sys"
      "value"               = var.sys
      "propagate_at_launch" = true
    },
  ]
}
