variable "name" {
  type    = string
  default = ""
}

variable "security_group_ids" {
  type = list(string)
}

variable "subnet_ids" {
  type = list(string)

  validation {
    condition     = length(var.subnet_ids) >= 2
    error_message = "Must provide at least two subnets"
  }

  validation {
    condition     = alltrue([for id in var.subnet_ids : id != ""])
    error_message = "Subnet ID must not be empty"
  }
}

variable "listeners" {
  type = map(object({
    port                     = string
    protocol                 = string
    default_target_group_arn = string
  }))
  default = {}
}
