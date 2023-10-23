# modules/vpc/subnet/variables.tf

variable "name" {
  description = "The name of the subnet"
  type        = string
}

variable "location" {
  description = "The region to create the subnet in"
  type        = string
}

variable "vpc_self_link" {
  description = "The self link of the VPC to create the subnet in"
  type        = string
}

variable "ip_cidr_range" {
  description = "The IP CIDR range of the subnet"
  type        = string
  default     = "10.0.0.0/12"
}

variable "cluster_secondary_ip_range" {
  description = "The secondary IP range of the cluster"
  type        = string
  default     = "10.16.0.0/12"
}

variable "services_secondary_ip_range" {
  description = "The secondary IP range of the services"
  type        = string
  default     = "10.32.0.0/12"
}
