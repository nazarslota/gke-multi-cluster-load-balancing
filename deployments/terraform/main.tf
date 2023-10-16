# main.tf

# ====================
# Providers
# ====================
provider "google" {
  project = var.project
}

# ====================
# Backend
# ====================
terraform {
  backend "gcs" {
    bucket = "gke-global-load-balancer-terraform-state-bucket"
    prefix = "terraform/state"
  }

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~>4.84"
    }
  }
}

# ====================
# GKE
# ====================
module "vpc" {
  source = "./modules/vpc"

  for_each = var.clusters

  name   = "${each.value.name}-${terraform.workspace}"
  region = replace(each.value.location, "-[a-z]$", "")
}

module "gke" {
  source = "./modules/gke"

  for_each = var.clusters

  name     = "${each.value.name}-${terraform.workspace}"
  location = each.value.location

  vpc                           = module.vpc[each.key].vpc
  subnet                        = module.vpc[each.key].subnet
  cluster_secondary_range_name  = module.vpc[each.key].cluster_secondary_range_name
  services_secondary_range_name = module.vpc[each.key].services_secondary_range_name
}

module "glb" {
  source = "./modules/glb/http"
  name   = "global-load-balancer-${terraform.workspace}"
}
