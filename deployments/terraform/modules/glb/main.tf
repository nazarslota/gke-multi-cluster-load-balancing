resource "google_compute_health_check" "default" {
  name                = "${var.name}-health-check"
  timeout_sec         = 5
  check_interval_sec  = 5
  healthy_threshold   = 2
  unhealthy_threshold = 2

  grpc_health_check {
    port = 50051
  }
}

resource "google_compute_backend_service" "default" {
  depends_on = [google_compute_health_check.default]

  name          = "${var.name}-backend-service"
  port_name     = "grpc"
  protocol      = "TCP"  # Changed to TCP
  timeout_sec   = 10
  health_checks = [google_compute_health_check.default.self_link]

  dynamic "backend" {
    for_each = var.negs
    content {
      group = "https://www.googleapis.com/compute/v1/projects/${var.project}/zones/${backend.value.zone}/networkEndpointGroups/${backend.value.name}"

      balancing_mode  = "CONNECTION"
      max_connections = 100
    }
  }
}

resource "google_compute_target_tcp_proxy" "default" {
  depends_on = [google_compute_backend_service.default]

  name             = "${var.name}-target-tcp-proxy"
  backend_service  = google_compute_backend_service.default.self_link
}

resource "google_compute_global_address" "default" {
  name = "${var.name}-global-address"
}

resource "google_compute_firewall" "default" {
  name    = "${var.name}-firewall"
  network = var.vpc_self_link

  allow {
    protocol = "tcp"
    ports    = ["50051"]
  }
  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_global_forwarding_rule" "default" {
  depends_on = [
    google_compute_firewall.default,
    google_compute_global_address.default,
    google_compute_target_tcp_proxy.default
  ]

  name                  = "${var.name}-forwarding-rule"
  load_balancing_scheme = "EXTERNAL"
  port_range            = "50051"

  target     = google_compute_target_tcp_proxy.default.self_link
  ip_address = google_compute_global_address.default.address
}
