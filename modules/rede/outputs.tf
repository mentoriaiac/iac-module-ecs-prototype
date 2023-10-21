output "subnet_id" {
  description = "Ids das subnets"
  value       = { for k, v in aws_subnet.subnets : k => v.id }
}

output "security_group_id" {
  description = "Id do security group"
  value       = aws_security_group.sg.id
}
