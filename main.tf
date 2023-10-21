terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.12.0"
    }
  }
}

provider "aws" {
  # Configuration options
}

module "rede_prototipo" {
  source   = "./modules/rede"
  vpc_cidr = "10.1.0.0/16"
  subnets = {
    primaria   = "10.1.1.0/24",
    secundaria = "10.1.2.0/24",
  }
}

resource "aws_ecs_cluster" "cluster" {
  name = "mentoria-teste"
}

resource "aws_ecs_cluster_capacity_providers" "example" {
  cluster_name = aws_ecs_cluster.cluster.name

  capacity_providers = ["FARGATE"]

  default_capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = "FARGATE"
  }
}
resource "aws_ecs_task_definition" "service" {
  family                   = "sample-fargate"
  memory                   = 512
  cpu                      = 256
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  container_definitions    = <<EOF
 [
        {
            "name": "fargate-app", 
            "image": "public.ecr.aws/docker/library/httpd:latest", 
            "portMappings": [
                {
                    "containerPort": 80, 
                    "hostPort": 80, 
                    "protocol": "tcp"
                }
            ], 
            "essential": true, 
            "entryPoint": [
                "sh",
        "-c"
            ], 
            "command": [
                "/bin/sh -c \"echo '<html> <head> <title>Amazon ECS Sample App</title> <style>body {margin-top: 40px; background-color: #333;} </style> </head><body> <div style=color:white;text-align:center> <h1>Amazon ECS Sample App</h1> <h2>Congratulations!</h2> <p>Your application is now running on a container in Amazon ECS.</p> </div></body></html>' >  /usr/local/apache2/htdocs/index.html && httpd-foreground\""
            ]
        }
    ]
  EOF
}

resource "aws_ecs_service" "apache" {
  name            = "apache"
  cluster         = aws_ecs_cluster.cluster.id
  task_definition = aws_ecs_task_definition.service.arn
  desired_count   = 1
  launch_type     = "FARGATE"
  network_configuration {
    subnets          = [module.rede_prototipo.subnet_id.primaria]
    assign_public_ip = true
    security_groups  = [module.rede_prototipo.security_group_id]
  }
}


resource "aws_ecs_task_definition" "service2" {
  family                   = "sample-fargate"
  memory                   = 512
  cpu                      = 256
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  container_definitions    = <<EOF
 [
        {
            "name": "fargate-app", 
            "image": "public.ecr.aws/docker/library/httpd:latest", 
            "portMappings": [
                {
                    "containerPort": 80, 
                    "hostPort": 80, 
                    "protocol": "tcp"
                }
            ], 
            "essential": true, 
            "entryPoint": [
                "sh",
        "-c"
            ], 
            "command": [
                "/bin/sh -c \"echo '<html> <head> <title>Amazon ECS Sample App</title> <style>body {margin-top: 40px; background-color: #333;} </style> </head><body> <div style=color:white;text-align:center> <h1>Amazon ECS Sample App</h1> <h2>Congratulations!</h2> <p>Your application is now running on a container in Amazon ECS.</p> </div></body></html>' >  /usr/local/apache2/htdocs/index.html && httpd-foreground\""
            ]
        }
    ]
  EOF
}

resource "aws_ecs_service" "apache2" {
  name            = "apache2"
  cluster         = aws_ecs_cluster.cluster.id
  task_definition = aws_ecs_task_definition.service2.arn
  desired_count   = 1
  launch_type     = "FARGATE"
  network_configuration {
    subnets          = [module.rede_prototipo.subnet_id.secundaria]
    assign_public_ip = true
    security_groups  = [module.rede_prototipo.security_group_id]
  }
}
