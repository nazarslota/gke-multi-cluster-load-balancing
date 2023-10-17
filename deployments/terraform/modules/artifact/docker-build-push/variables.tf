# modules/docker-build-push/main.tf

variable "project" {
  type        = string
  description = "The name of the project to push to"
}

variable "repository" {
  type        = string
  description = "The name of the repository to push to"
}

variable "application" {
  type        = string
  description = "The name of the application to push to"
}

variable "location" {
  type        = string
  description = "The location of the application to push to"
  default     = "us-east4"
}

variable "build_number" {
  type        = string
  description = "The build number to use for the image"
}
