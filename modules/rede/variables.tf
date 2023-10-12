variable "vpc_cidr" {
  description = "Bloco cidr da VPC"
  default     = "10.0.0.0/16"
  type        = string
}

variable "subnets" {
  description = "Mapa de subnets"
  type        = map(string)
  default     = {}
}

variable "ingress_rules" {
  description = "Lista de regras de ingresso"
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
}

variable "egress_rules" {
  description = "Lista de regras de egresso"
  type = list(object({
    from_port        = number
    to_port          = number
    protocol         = string
    cidr_blocks      = list(string)
    ipv6_cidr_blocks = optional(list(string))
  }))
  default = [{
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }]
}
