# modules/vpc/subnet/output.tf

output "name" {
  value       = google_compute_subnetwork.default.name
  description = "The subnet name"
}

output "self_link" {
  value       = google_compute_subnetwork.default.self_link
  description = "The subnet self link"
}

output "cluster_secondary_range_name" {
  value       = google_compute_subnetwork.default.secondary_ip_range.0.range_name
  description = "The cluster secondary range name"
}

output "services_secondary_range_name" {
  value       = google_compute_subnetwork.default.secondary_ip_range.1.range_name
  description = "The services secondary range name"
}
