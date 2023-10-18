# modules/kubernetes/variables.tf

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

variable "artifact_username" {
  description = "The username to use for artifact storage"
  type        = string
}

variable "artifact_password" {
  description = "The password to use for artifact storage"
  type        = string
}

variable "artifact_repository" {
  description = "The repository to store artifacts in"
  type        = string
}

variable "artifact_application" {
  description = "The application to store artifacts in"
  type        = string
}

variable "artifact_location" {
  description = "The location to store artifacts in"
  type        = string
}
