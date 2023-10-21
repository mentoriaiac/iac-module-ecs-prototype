resource "aws_ecs_service" "service" {
  name            = var.name
  cluster         = var.cluster_id
  task_definition = aws_ecs_task_definition.task.arn
  desired_count   = var.desired_count
  launch_type     = "FARGATE"
  network_configuration {
    subnets          = var.subnets
    assign_public_ip = true
    security_groups  = var.security_groups
  }
}

resource "aws_ecs_task_definition" "task" {
  family                   = var.name
  memory                   = var.resources.memory
  cpu                      = var.resources.cpu
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  container_definitions    = var.container_definitions
}
