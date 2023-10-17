# modules/gke/variables.tf.tf

variable "name" {
  description = "The name of the GKE cluster"
  type        = string
}

variable "location" {
  description = "The location (region or zone) of the cluster"
  type        = string
}

variable "node_count" {
  description = "The number of nodes in the cluster's default node pool"
  type        = number
  default     = 1
}

variable "machine_type" {
  description = "The type of machine to use for nodes in the cluster's default node pool"
  type        = string
  default     = "e2-micro"
}

variable "vpc" {
  description = "The VPC network for the GKE cluster"
  type        = string
}

variable "subnet" {
  description = "The name of the subnet for the GKE cluster"
  type        = string
}

variable "cluster_secondary_range_name" {
  description = "The name of the secondary range for the GKE cluster"
  type        = string
}

variable "services_secondary_range_name" {
  description = "The name of the secondary range for the GKE cluster"
  type        = string
}
