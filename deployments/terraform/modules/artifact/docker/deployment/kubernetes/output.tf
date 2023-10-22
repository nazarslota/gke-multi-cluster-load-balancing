# modules/artifact/docker/deployment/kubernetes/output.tf

output "negs" {
  description = "Details for the Network Endpoint Group (NEG) per zone"
  value       = [
    for zone in try(jsondecode(data.local_file.negs.content)["zones"], []) : {
      name = jsondecode(data.local_file.negs.content)["network_endpoint_groups"]["8080"],
      zone = zone
    }
  ]

  depends_on = [
    data.local_file.negs
  ]
}
