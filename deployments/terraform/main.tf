# main.tf

# ====================
# Providers
# ====================
provider "google" {
  project = var.project
}

data "google_client_config" "provider" {}

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

# Ashburn Virginia
locals {
  ashburn = {
    name     = "ashburn-virginia-${terraform.workspace}"
    location = "us-east4"
  }
}

module "ashburn_virginia_vpc" {
  source = "./modules/vpc"

  name   = local.ashburn.name
  region = replace(local.ashburn.location, "-[a-z]$", "") # Remove zone suffix.
}

module "ashburn_virginia_gke" {
  source = "./modules/gke"

  name     = local.ashburn.name
  location = local.ashburn.location

  vpc                           = module.ashburn_virginia_vpc.vpc
  subnet                        = module.ashburn_virginia_vpc.subnet
  cluster_secondary_range_name  = module.ashburn_virginia_vpc.cluster_secondary_range_name
  services_secondary_range_name = module.ashburn_virginia_vpc.services_secondary_range_name

  depends_on = [
    module.ashburn_virginia_vpc,
  ]
}

# ====================
# Artifact
# ====================
locals {
  artifact_application  = var.deployment_app
  artifact_repository   = "${var.deployment_app}-${terraform.workspace}"
  artifact_location     = local.ashburn.location
  artifact_build_number = var.deployment_build
}

resource "google_service_account" "artifact_service_account" {
  account_id   = "artifact-registry-account"
  display_name = "Artifact Registry Service Account"
  project      = var.project
}

resource "google_project_iam_member" "artifact_service_account_iam_member" {
  project = var.project
  role    = "roles/artifactregistry.writer"
  member  = "serviceAccount:${google_service_account.artifact_service_account.email}"

  depends_on = [
    google_service_account.artifact_service_account,
  ]
}

resource "time_rotating" "artifact_service_account_key_rotation" {
  rotation_minutes = 10
  depends_on       = [
    google_project_iam_member.artifact_service_account_iam_member,
  ]
}

resource "google_service_account_key" "artifact_service_account_key" {
  service_account_id = google_service_account.artifact_service_account.id
  public_key_type    = "TYPE_X509_PEM_FILE"

  lifecycle {
    create_before_destroy = true
  }

  keepers = {
    rotation_time = time_rotating.artifact_service_account_key_rotation.rotation_rfc3339
  }

  depends_on = [
    time_rotating.artifact_service_account_key_rotation,
  ]
}

module "artifact_docker_build" {
  source = "./modules/artifact/docker/build"

  project  = var.project
  location = local.artifact_location

  application  = local.artifact_application
  repository   = local.artifact_repository
  build_number = local.artifact_build_number

  artifact_service_account_key_base64 = google_service_account_key.artifact_service_account_key.private_key

  depends_on = [
    module.ashburn_virginia_gke,
    google_service_account_key.artifact_service_account_key,
  ]
}

# ====================
# Deployment Ashburn Virginia
# ====================

module "ashburn_virginia_deployment" {
  source = "./modules/artifact/docker/deployment/kubernetes"

  host                   = module.ashburn_virginia_gke.endpoint
  token                  = data.google_client_config.provider.access_token
  cluster_ca_certificate = base64decode(module.ashburn_virginia_gke.cluster_ca_certificate)


  artifact_application = local.artifact_application
  artifact_location    = local.artifact_location
  artifact_repository  = local.artifact_repository

  artifact_service_account_key_base64 = google_service_account_key.artifact_service_account_key.private_key
}

# ====================
# Load Balancer
# ====================
module "global_load_balancer" {
  source = "./modules/load-balancers/global/http"
  name   = "global-load-balancer-${terraform.workspace}"
}
