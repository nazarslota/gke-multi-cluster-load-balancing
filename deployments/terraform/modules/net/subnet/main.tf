# modules/vpc/subnets/main.tf

locals {
  region = replace(var.location, "-[a-z]$", "") # Remove zone suffix.
}

resource "google_compute_subnetwork" "default" {
  name    = "${var.name}-subnet"
  region  = local.region
  network = var.vpc_self_link

  ip_cidr_range = var.ip_cidr_range
  secondary_ip_range {
    range_name    = "${var.name}-cluster-secondary-range"
    ip_cidr_range = var.cluster_secondary_ip_range
  }
  secondary_ip_range {
    range_name    = "${var.name}-services-secondary-range"
    ip_cidr_range = var.services_secondary_ip_range
  }
}
