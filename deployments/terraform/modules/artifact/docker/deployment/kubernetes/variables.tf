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

variable "artifact_service_account_key_base64" {
  description = "The service account to use for artifact access (base64 encoded)"
  type        = string
  sensitive   = true
}
