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
  name        = "${var.name}-backend-service"
  port_name   = "http"
  protocol    = "HTTP"
  timeout_sec = 10

  health_checks = [
    google_compute_health_check.default.self_link,
  ]

  depends_on = [
    google_compute_health_check.default,
  ]
}

resource "google_compute_url_map" "default" {
  name            = "${var.name}-url-map"
  default_service = google_compute_backend_service.default.self_link

  depends_on = [
    google_compute_backend_service.default,
  ]
}


resource "google_compute_target_http_proxy" "default" {
  name    = "${var.name}-target-http-proxy"
  url_map = google_compute_url_map.default.self_link

  depends_on = [
    google_compute_url_map.default,
  ]
}

resource "google_compute_global_address" "default" {
  name = "${var.name}-global-address"
}

resource "google_compute_global_forwarding_rule" "default" {
  name = "${var.name}-forwarding-rule"

  target                = google_compute_target_http_proxy.default.self_link
  load_balancing_scheme = "EXTERNAL"

  ip_address = google_compute_global_address.default.address
  port_range = "8080"

  depends_on = [
    google_compute_global_address.default,
    google_compute_target_http_proxy.default,
  ]
}
