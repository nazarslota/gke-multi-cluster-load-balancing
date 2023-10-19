# modules/artifact/docker/deployment/kubernetes/output.tf

output "neg_self_link" {
  value = data.google_compute_network_endpoint_group.neg.self_link
}
