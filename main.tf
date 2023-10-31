terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.12.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
  # Configuration options
}

module "rede" {
  source   = "./modules/rede"
  vpc_cidr = "10.1.0.0/16"

  subnets = {
    primaria   = "10.1.1.0/24"
    secundaria = "10.1.2.0/24"
  }

  ingress_rules = [
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
}

module "cluster" {
  source = "./modules/ecs-cluster"

  name = "mentoria-teste"
}

resource "aws_lb_target_group" "maria_quiteria_web" {
  name        = "maria-quiteria-web"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = module.rede.vpc_id
}

data "aws_iam_role" "ecs_task_execution_role" {
  name = "ecsTaskExecutionRole"
}

module "maria_quiteria_web" {
  source = "./modules/ecs-app"

  name             = "maria_quiteria_web"
  cluster_id       = module.cluster.cluster_id
  desired_count    = 1
  subnets          = [module.rede.subnet_id.primaria]
  security_groups  = [module.rede.security_group_id]
  target_group_arn = aws_lb_target_group.maria_quiteria_web.arn
  execution_role_arn = data.aws_iam_role.ecs_task_execution_role.arn

  resources = {
    cpu    = 256
    memory = 512
  }

  container_definitions = <<EOF
    [
      {
        "name": "fargate-app",
        "image": "laoqui/maria-quiteria:v2",
        "portMappings": [
          {
            "containerPort": 80,
            "hostPort": 80,
            "protocol": "tcp"
          }
        ],
        "essential": true,
        "entryPoint": ["python"],
        "command": ["manage.py", "runserver", "0.0.0.0:80"],
        "environment": [
          { 
            "name": "DJANGO_CONFIGURATION",
            "value": "Prod"
          },
          { 
            "name": "DJANGO_SECRET_KEY",
            "value": "secret"
          },
          { 
            "name": "DJANGO_ALLOWED_HOSTS",
            "value": "lb-1689168370.us-east-1.elb.amazonaws.com"
          }
        ],
        "logConfiguration": {
          "logDriver": "awslogs",
          "options": {
            "awslogs-create-group": "true",
            "awslogs-group": "maria-quiteria-web",
            "awslogs-region": "us-east-1",
            "awslogs-stream-prefix": "maria-quiteria-web",
            "mode": "non-blocking", 
            "max-buffer-size": "25m" 
          }
        }
      }
    ]
    EOF
}

module "lb" {
  source = "./modules/load-balancer"

  name = "lb"

  security_group_ids = [
    module.rede.security_group_id,
  ]

  subnet_ids = [
    module.rede.subnet_id.primaria,
    module.rede.subnet_id.secundaria,
  ]

  listeners = {
    http = {
      port                     = "80"
      protocol                 = "HTTP"
      default_target_group_arn = aws_lb_target_group.maria_quiteria_web.arn
    },
  }
}