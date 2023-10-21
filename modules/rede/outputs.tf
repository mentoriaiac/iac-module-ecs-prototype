output "subnet_id" {
  value = { for k, v in aws_subnet.ecs : k => v.id }
}

output "security_group_id" {
  value = aws_security_group.ecs.id
}
