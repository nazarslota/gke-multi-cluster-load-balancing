# modules/vpc/main.tf

resource "google_compute_network" "default" {
  name                    = "${var.name}-vpc"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "default" {
  name    = "${var.name}-subnet"
  region  = var.region
  network = google_compute_network.default.name

  ip_cidr_range = "10.0.0.0/12"

  secondary_ip_range {
    range_name    = "${var.name}-cluster-secondary-range"
    ip_cidr_range = "10.16.0.0/12"
  }

  secondary_ip_range {
    range_name    = "${var.name}-services-secondary-range"
    ip_cidr_range = "10.32.0.0/12"
  }

  depends_on = [
    google_compute_network.default
  ]
}
