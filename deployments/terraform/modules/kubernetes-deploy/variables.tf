# modules/kubernetes-deploy/variables.tf

variable "host" {
  description = "The host to deploy to"
  type        = string
}

variable "token" {
  description = "The token to use for authentication"
  type        = string
}

variable "cluster_ca_certificate" {
  description = "The CA certificate for the cluster"
  type        = string
}
