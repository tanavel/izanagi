output "security_alb_sg_id" {
  value = aws_security_group.alb.id
}

output "security_app_sg_id" {
  value = aws_security_group.app.id
}

output "security_db_sg_id" {
  value = aws_security_group.db.id
}
