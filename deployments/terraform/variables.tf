# variables.tf.tf

variable "project" {
  description = "The GCP project to deploy to"
  type        = string
}

variable "app" {
  description = "The name of the application"
  type        = string
}

variable "build" {
  description = "The build number of the application. For example, the git commit SHA"
  type        = string
}
