resource "aws_lb" "lb" {
  name               = var.name
  internal           = var.internal
  load_balancer_type = var.type

  security_groups = var.security_group_ids
  subnets         = var.subnet_ids
}

resource "aws_lb_listener" "listeners" {
  for_each = var.listeners

  load_balancer_arn = aws_lb.lb.arn
  port              = each.value.port
  protocol          = each.value.protocol

  default_action {
    type             = "forward"
    target_group_arn = each.value.default_target_group_arn
  }
}
