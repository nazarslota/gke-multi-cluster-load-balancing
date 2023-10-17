# modules/docker-build-push/main.tf

variable "project" {
  description = "The name of the project to push to"
  type        = string
}

variable "repository" {
  description = "The name of the repository to push to"
  type        = string
}

variable "application" {
  description = "The name of the application to push to"
  type        = string
}

variable "location" {
  description = "The location of the application to push to"
  type        = string
  default     = "us-east4"
}

variable "build_number" {
  description = "The build number to use for the image"
  type        = string
}
