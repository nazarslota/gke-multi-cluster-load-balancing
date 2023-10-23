# modules/glb/http/main.tf

resource "google_compute_health_check" "default" {
  name                = "${var.name}-health-check"
  timeout_sec         = 5
  check_interval_sec  = 5
  healthy_threshold   = 2
  unhealthy_threshold = 2

  http_health_check {
    request_path = var.health_check_path
    port         = var.health_check_port
  }
}

resource "google_compute_backend_service" "default" {
  depends_on = [google_compute_health_check.default]

  name          = "${var.name}-backend-service"
  port_name     = "http"
  protocol      = "HTTP"
  timeout_sec   = 10
  health_checks = [google_compute_health_check.default.self_link]

  dynamic "backend" {
    for_each = var.negs
    content {
      max_rate       = 100
      balancing_mode = "RATE"

      group = "https://www.googleapis.com/compute/v1/projects/${var.project}/zones/${backend.value.zone}/networkEndpointGroups/${backend.value.name}"
    }
  }
}

resource "google_compute_url_map" "default" {
  depends_on = [google_compute_backend_service.default]

  name            = "${var.name}-url-map"
  default_service = google_compute_backend_service.default.self_link
}

resource "google_compute_target_http_proxy" "default" {
  depends_on = [google_compute_url_map.default]

  name    = "${var.name}-target-http-proxy"
  url_map = google_compute_url_map.default.self_link
}

resource "google_compute_global_address" "default" {
  name = "${var.name}-global-address"
}

resource "google_compute_firewall" "default" {
  name    = "${var.name}-firewall"
  network = var.vpc_self_link

  allow {
    protocol = "tcp"
    ports    = ["8080"]
  }
  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_global_forwarding_rule" "default" {
  depends_on = [
    google_compute_firewall.default, google_compute_global_address.default, google_compute_target_http_proxy.default
  ]

  name = "${var.name}-forwarding-rule"

  target                = google_compute_target_http_proxy.default.self_link
  load_balancing_scheme = "EXTERNAL"

  ip_address = google_compute_global_address.default.address
  port_range = "8080"
}
