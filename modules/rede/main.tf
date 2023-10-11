resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
}

resource "aws_route" "internet_gateway" {
  route_table_id         = aws_vpc.main.default_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.gw.id
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
}

resource "aws_subnet" "ecs" {
  for_each   = var.subnets
  vpc_id     = aws_vpc.main.id
  cidr_block = each.value
}

resource "aws_security_group" "ecs" {
  name   = "ecs-teste"
  vpc_id = aws_vpc.main.id

  dynamic "ingress" {
    for_each = var.ingress_rules
    content {
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}
