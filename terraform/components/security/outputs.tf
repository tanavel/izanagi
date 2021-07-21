output "security_sg_alb_id" {
  value = aws_security_group.alb.id
}

output "security_sg_app_id" {
  value = aws_security_group.app.id
}

output "security_sg_db_id" {
  value = aws_security_group.db.id
}

output "security_iam_role_ecs_instance_profile_name" {
  value = aws_iam_instance_profile.ecs_instance.name
}

output "security_service_role_ecs_arn" {
  value = aws_iam_service_linked_role.ecs.arn
}
