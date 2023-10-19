# modules/glb/http/variables.tf.tf

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

variable "neg_self_link" {
  description = "Self link of NEG"
}
