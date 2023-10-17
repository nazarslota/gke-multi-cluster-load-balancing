# variables.tf

variable "project" {
  description = "The GCP project to deploy to"
  type        = string
}

variable "application" {
  description = "The name of the application"
  type        = string
}
