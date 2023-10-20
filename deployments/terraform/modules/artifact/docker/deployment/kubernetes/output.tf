# modules/artifact/docker/deployment/kubernetes/output.tf

output "neg_id" {
  value = "" // "/${data.kubernetes_service.neg.metadata.0.annotations["cloud.google.com/neg-status"]}"
}
