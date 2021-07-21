output "network_vpc_id" {
  value = aws_vpc.this.id
}

output "network_subnet_public_1_id" {
  value = aws_subnet.public_1.id
}

output "network_subnet_public_2_id" {
  value = aws_subnet.public_2.id
}

output "network_subnet_public_3_id" {
  value = aws_subnet.public_3.id
}

output "network_subnet_private_1_id" {
  value = aws_subnet.private_1.id
}

output "network_subnet_private_2_id" {
  value = aws_subnet.private_2.id
}

output "network_subnet_private_3_id" {
  value = aws_subnet.private_3.id
}
