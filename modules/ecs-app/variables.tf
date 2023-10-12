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

variable "resources" {
  type = object({
    cpu    = number
    memory = number
  })
}

variable "container_definitions" {
  type = string
}
  
