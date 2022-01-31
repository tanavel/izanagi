#================================================#
# ECS
# NOTE:
# - 本来はContainer Insightsを有効化したいが、料金が発生するのでコメントアウト
#================================================#
resource "aws_ecs_cluster" "this" {
  name = "${var.sys}-${terraform.workspace}-app-cluster"
  tags = {
    Name = "${var.sys}-${terraform.workspace}-app-cluster"
  }

  #   setting {
  #     name  = "containerInsights"
  #     value = "enabled"
  #   }
}

resource "aws_ecs_service" "this" {
  cluster         = aws_ecs_cluster.this.id
  name            = "${var.sys}-${terraform.workspace}-app-svc"
  task_definition = aws_ecs_task_definition.this.arn
  desired_count   = 1
  iam_role        = data.terraform_remote_state.security.outputs.security_service_role_ecs_arn
  load_balancer {
    target_group_arn = aws_lb_target_group.this.arn
    container_name   = "web"
    container_port   = "80"
  }

  tags = {
    Name = "${var.sys}-${terraform.workspace}-app-svc"
  }
}

resource "aws_ecs_task_definition" "this" {
  family = "${var.sys}-${terraform.workspace}-app-task-def"
  container_definitions = jsonencode([
    {
      name   = "web"
      image  = "nginx"
      memory = 256
      portMappings = [
        {
          containerPort = 80
          hostPort      = 0
        }
      ]
    }
  ])

  tags = {
    Name = "${var.sys}-${terraform.workspace}-app-task-def"
  }
}
