variable "vpc_cidr" {
  description = "Bloco cidr da VPC"
  default     = "10.0.0.0/16"
  type        = string
}

variable "subnets" {
  type    = map(string)
  default = {}
}
