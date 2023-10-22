# modules/glb/http/variables.tf.tf

variable "project" {
  description = "Project ID"
  type        = string
}

variable "name" {
  description = "Name of the GLB"
  type        = string
}

variable "health_check_path" {
  description = "Path to health check"
  type        = string
  default     = "/healthz"
}

variable "health_check_port" {
  description = "Port to health check"
  type        = number
  default     = 8080
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
