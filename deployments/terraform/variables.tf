# variables.tf

variable "project" {
  description = "The GCP project to deploy to"
  type        = string
}

variable "application" {
  description = "The name of the application"
  type        = string
}

variable "clusters" {
  description = "Map of GKE clusters and their configurations"
  type        = map(object({
    name     = string
    location = string
  }))

  default = {
    ashburn-virginia = {
      name     = "ashburn-virginia"
      location = "us-east4"
    }
  }
}

#gcloud container clusters get-credentials ashburn-virginia-cluster \
#--region us-east4 \
#--project gke-global-load-balancer
#
#gcloud compute backend-services add-backend balancer-backend-service \
#--global \
#--network-endpoint-group k8s1-d9913234-default-hello-world-8080-54ae5bc9 \
#--network-endpoint-group-zone=us-east4-a \
#--balancing-mode=RATE \
#--max-rate-per-endpoint=100
