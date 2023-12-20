variable "name" {
  type = string
}

variable "cluster_id" {
  description = "ID do cluster"
  type        = string
}

variable "desired_count" {
  type = number
}

variable "subnets" {
  type = list(string)
}

variable "security_groups" {
  type = list(string)
}

variable "assign_public_ip" {
  type = bool
  default = false
}

variable "resources" {
  type = object({
    cpu    = number
    memory = number
  })
}

variable "container_definitions" {
  type = string
}

variable "execution_role_arn" {
  type = string
  default = ""
}

variable "load_balancer" {
  type = object({
    target_group_arn = string
    container_name = string
    container_port = number
  })
  default = null
}