# modules/gke/main.tf

resource "google_container_cluster" "default" {
  name     = "${var.name}-cluster"
  location = var.location

  network    = var.vpc
  subnetwork = var.subnet

  remove_default_node_pool = true
  initial_node_count       = 1

  master_auth {
    client_certificate_config {
      issue_client_certificate = false
    }
  }

  # This block enables VPC-native clusters. Required for NEGs.
  ip_allocation_policy {
    cluster_secondary_range_name  = var.cluster_secondary_range_name
    services_secondary_range_name = var.services_secondary_range_name
  }
}

resource "google_container_node_pool" "default" {
  depends_on = [google_container_cluster.default]

  name    = "${var.name}-node-pool"
  cluster = google_container_cluster.default.name

  location   = var.location
  node_count = var.node_count

  node_config {
    preemptible  = false
    machine_type = var.machine_type
  }
}
