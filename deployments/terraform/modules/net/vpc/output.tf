# modules/output/output.tf

output "name" {
  value       = google_compute_network.default.name
  description = "The VPC name"
}

output "self_link" {
  value       = google_compute_network.default.self_link
  description = "The VPC self link"
}
