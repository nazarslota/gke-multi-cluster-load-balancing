# variables.tf

variable "project" {
  description = "The GCP project to deploy to"
  type        = string
}

variable "application" {
  description = "The name of the application"
  type        = string
}

variable "build_number" {
  description = "The build number of the application. For example, the git commit SHA"
  type        = string
}
