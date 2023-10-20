# modules/artifact/docker/deployment/kubernetes/variables.tf

variable "project" {
  description = "The project to deploy to"
  type        = string
}

variable "name" {
  description = "The name of the application"
  type        = string
}

variable "cluster_name" {
  description = "The name of the cluster to deploy to"
  type        = string
}

variable "cluster_endpoint" {
  description = "The host to deploy to"
  type        = string
}

variable "cluster_token" {
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

variable "artifact_build_number" {
  description = "The build number to store artifacts in"
  type        = string
}

variable "artifact_service_account_key_base64" {
  description = "The service account to use for artifact access (base64 encoded)"
  type        = string
  sensitive   = true
}
