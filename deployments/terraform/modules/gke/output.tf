# modules/gke/output.tf

output "cluster_name" {
  value = google_container_cluster.default.name
}

output "cluster_node_pool_name" {
  value = google_container_node_pool.default.name
}

output "endpoint" {
  value = google_container_cluster.default.endpoint
}

output "cluster_ca_certificate" {
  value = google_container_cluster.default.master_auth.0.cluster_ca_certificate
}
