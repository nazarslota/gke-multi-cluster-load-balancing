variable "project" {
  description = "Project ID"
  type        = string
}

variable "name" {
  description = "Name of the GLB"
  type        = string
}

variable "vpc_self_link" {
  description = "VPC Self Link"
  type        = string
}

variable "negs" {
  description = "List of Network Endpoint Groups (NEGs) details"
  type        = list(object({
    name = string
    zone = string
  }))
  default = []
}
