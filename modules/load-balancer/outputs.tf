output "lb_arn" {
  value = aws_lb.lb.arn
}

output "listener_arns" {
  value = { for k, v in aws_lb_listener.listeners : k => v.arn }
}

output "lb_dns_name" {
  value = aws_lb.lb.dns_name
}