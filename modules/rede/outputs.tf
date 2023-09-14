output "subnet_id" {
  value = aws_subnet.ecs.id
}

output "security_group_id" {
  value = aws_security_group.ecs.id
}
