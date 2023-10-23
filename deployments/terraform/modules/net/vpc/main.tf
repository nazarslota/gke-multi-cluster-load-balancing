# modules/vpc/main.tf

resource "google_compute_network" "default" {
  name                    = "${var.name}-vpc"
  auto_create_subnetworks = false
}
