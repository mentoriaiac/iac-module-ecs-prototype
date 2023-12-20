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

module "rede_prototipo" {
  source   = "./modules/rede"
  vpc_cidr = "10.1.0.0/16"

  subnets = {
    primaria   = "10.1.1.0/24",
    secundaria = "10.1.2.0/24",
  }

  ingress_rules = [
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      from_port   = 3306
      to_port     = 3306
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
  ]
}

module "cluster" {
  source = "./modules/ecs-cluster"

  name = "mentoria-teste"
}

module "apache" {
  source = "./modules/ecs-app"

  name             = "apache"
  cluster_id       = module.cluster.cluster_id
  desired_count    = 1
  subnets          = [module.rede_prototipo.subnet_id.primaria]
  security_groups  = [module.rede_prototipo.security_group_id]
  target_group_arn = aws_lb_target_group.apache1.arn

  resources = {
    cpu    = 256
    memory = 512
  }

  container_definitions = <<EOF
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
          "/bin/sh -c \"echo '<html> <head> <title>Amazon ECS Sample App 1</title> <style>body {margin-top: 40px; background-color: #333;} </style> </head><body> <div style=color:white;text-align:center> <h1>Amazon ECS Sample App 1</h1> <h2>Congratulations!</h2> <p>Your application is now running on a container in Amazon ECS.</p> </div></body></html>' >  /usr/local/apache2/htdocs/index.html && httpd-foreground\""
        ]
      }
    ]
    EOF

}

module "apache2" {
  source = "./modules/ecs-app"

  name             = "apache2"
  cluster_id       = module.cluster.cluster_id
  desired_count    = 1
  subnets          = [module.rede_prototipo.subnet_id.secundaria]
  security_groups  = [module.rede_prototipo.security_group_id]
  target_group_arn = aws_lb_target_group.apache2.arn

  resources = {
    cpu    = 256
    memory = 512
  }

  container_definitions = <<EOF
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
          "/bin/sh -c \"echo '<html> <head> <title>Amazon ECS Sample App 2</title> <style>body {margin-top: 40px; background-color: #333;} </style> </head><body> <div style=color:white;text-align:center> <h1>Amazon ECS Sample App 2</h1> <h2>Congratulations!</h2> <p>Your application is now running on a container in Amazon ECS.</p> </div></body></html>' >  /usr/local/apache2/htdocs/index.html && httpd-foreground\""
        ]
      }
    ]
    EOF

}

module "lb" {
  source = "./modules/load-balancer"

  name = "apache"

  security_group_ids = [
    module.rede_prototipo.security_group_id,
  ]

  subnet_ids = [
    module.rede_prototipo.subnet_id.primaria,
    module.rede_prototipo.subnet_id.secundaria,
  ]

  listeners = {
    http = {
      port                     = "80"
      protocol                 = "HTTP"
      default_target_group_arn = aws_lb_target_group.apache1.arn
    },
    https = {
      port                     = "443"
      protocol                 = "HTTP"
      default_target_group_arn = aws_lb_target_group.apache1.arn
    },
  }
}


resource "aws_lb_listener_rule" "apache1" {
  listener_arn = module.lb.listener_arns["http"]
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.apache1.arn
  }

  condition {
    query_string {
      key   = "apache"
      value = "1"
    }
  }
}

resource "aws_lb_listener_rule" "apache2" {
  listener_arn = module.lb.listener_arns["http"]
  priority     = 101

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.apache2.arn
  }

  condition {
    query_string {
      key   = "apache"
      value = "2"
    }
  }
}

resource "aws_lb_target_group" "apache1" {
  name        = "apache1"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = module.rede_prototipo.vpc_id
}

resource "aws_lb_target_group" "apache2" {
  name        = "apache2"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = module.rede_prototipo.vpc_id
}
