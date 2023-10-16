# modules/gke/output.tf

output "cluster_name" {
  value = google_container_cluster.default.name
}

output "cluster_node_pool_name" {
  value = google_container_node_pool.default.name
}
