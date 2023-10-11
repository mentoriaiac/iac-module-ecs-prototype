variable "vpc_cidr" {
  description = "Bloco cidr da VPC"
  default     = "10.0.0.0/16"
  type        = string
}

variable "subnets" {
  type    = map(string)
  default = {}
}

variable "ingress_rules" {
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
}
