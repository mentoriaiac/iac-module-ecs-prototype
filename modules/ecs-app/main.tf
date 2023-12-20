resource "aws_ecs_service" "service" {
  name            = var.name
  cluster         = var.cluster_id
  task_definition = aws_ecs_task_definition.task.arn
  desired_count   = var.desired_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.subnets
    assign_public_ip = var.assign_public_ip
    security_groups  = var.security_groups
  }

  dynamic "load_balancer" {
    for_each = toset(var.load_balancer == null ? [] : [var.load_balancer])
  
    content {
      target_group_arn = load_balancer.value.target_group_arn
      container_name   = load_balancer.value.container_name
      container_port   = load_balancer.value.container_port
    }
  }
}

resource "aws_ecs_task_definition" "task" {
  family                   = var.name
  memory                   = var.resources.memory
  cpu                      = var.resources.cpu
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  container_definitions    = var.container_definitions
  execution_role_arn       = var.execution_role_arn
}