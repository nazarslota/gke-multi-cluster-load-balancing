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

resource "google_artifact_registry_repository" "default" {
  repository_id = var.application
  location      = "us-east4"
  format        = "DOCKER"

  description = "GKE repository"
}

resource "null_resource" "docker_build_and_push" {
  triggers = {
    always_run = timestamp()
  }

  provisioner "local-exec" {
    command = <<EOL
      cd ../../

      docker login -u _json_key --password-stdin https://${google_artifact_registry_repository.default.location}-docker.pkg.dev < $GOOGLE_APPLICATION_CREDENTIALS

      docker build \
        --file deployments/docker/Dockerfile \
        --tag "${google_artifact_registry_repository.default.location}-docker.pkg.dev/${var.project}/${var.application}/${var.application}:${var.build_number}" \
        --tag "${google_artifact_registry_repository.default.location}-docker.pkg.dev/${var.project}/${var.application}/${var.application}:latest" \
        .

      docker push "${google_artifact_registry_repository.default.location}-docker.pkg.dev/${var.project}/${var.application}/${var.application}:${var.build_number}"
      docker push "${google_artifact_registry_repository.default.location}-docker.pkg.dev/${var.project}/${var.application}/${var.application}:latest"
    EOL
  }

  depends_on = [
    google_artifact_registry_repository.default
  ]
}

module "global_load_balancer" {
  source = "./modules/glb/http"
  name   = "global-load-balancer-${terraform.workspace}"
}
