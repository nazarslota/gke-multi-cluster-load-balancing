# modules/artifact/docker/deployment/kubernetes/variables.tf

variable "project" {
  description = "The project to deploy to"
  type        = string
}

variable "name" {
  description = "The name of the application"
  type        = string
}

variable "repository" {
  description = "The repository to store artifacts in"
  type        = string
}

variable "application" {
  description = "The application to store artifacts in"
  type        = string
}

variable "location" {
  description = "The location to store artifacts in"
  type        = string
}

variable "build_number" {
  description = "The build number to store artifacts in"
  type        = string
}

variable "service_account_key_base64" {
  description = "The service account to use for artifact access (base64 encoded)"
  type        = string
  sensitive   = true
}
