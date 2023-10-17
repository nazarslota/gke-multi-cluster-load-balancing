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
# Ashburn Virginia
# ====================
locals {
  ashburn = {
    name     = "ashburn-virginia-${terraform.workspace}"
    location = "us-east4"
  }
}

module "ashburn_vpc" {
  source = "./modules/vpc"

  name   = local.ashburn.name
  region = replace(local.ashburn.location, "-[a-z]$", "") # Remove zone suffix.
}

module "ashburn_gke" {
  source = "./modules/gke"

  name     = local.ashburn.name
  location = local.ashburn.location

  vpc                           = module.ashburn_vpc.vpc
  subnet                        = module.ashburn_vpc.subnet
  cluster_secondary_range_name  = module.ashburn_vpc.cluster_secondary_range_name
  services_secondary_range_name = module.ashburn_vpc.services_secondary_range_name
}

module "artifact_docker_build_push" {
  source = "./modules/artifact/docker-build-push"

  project  = var.project
  location = local.ashburn.location

  application  = var.deployment_app
  repository   = "${var.deployment_app}-${terraform.workspace}"
  build_number = var.deployment_build
}

module "global_load_balancer" {
  source = "./modules/glb/http"
  name   = "global-load-balancer-${terraform.workspace}"
}
