# modules/glb/http/output.tf

output "backend" {
  value = {
    name = google_compute_backend_service.default.name
  }
}

output "address" {
  value = {
    name       = google_compute_global_address.default.name
    ip_address = google_compute_global_address.default.address
  }
  description = "The IP address of the GLB"
}

output "forwarding_rule" {
  value = {
    name       = google_compute_global_forwarding_rule.default.name
    ip_address = google_compute_global_forwarding_rule.default.ip_address
  }
}

