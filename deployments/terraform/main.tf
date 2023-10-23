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
# Variables
# ====================
locals {
  virginia = {
    name     = "virginia-${terraform.workspace}"
    location = "us-east4"
  }

  milan = {
    name     = "milan-${terraform.workspace}"
    location = "europe-west8"
  }
}


# ====================
# VPC
# ====================
module "vpc" {
  source = "./modules/net/vpc"

  name = "vpc-${terraform.workspace}"
}

module "subnet_virginia" {
  source     = "./modules/net/subnet"
  depends_on = [module.vpc]

  name          = local.virginia.name
  location      = local.virginia.location
  vpc_self_link = module.vpc.self_link

  ip_cidr_range               = "10.0.0.0/20"   # Range: 10.0.0.0 - 10.0.15.255
  cluster_secondary_ip_range  = "10.0.16.0/20"  # Range: 10.0.16.0 - 10.0.31.255
  services_secondary_ip_range = "10.0.32.0/20"  # Range: 10.0.32.0 - 10.0.47.255
}

module "subnet_milan" {
  source     = "./modules/net/subnet"
  depends_on = [module.vpc]

  name          = local.milan.name
  location      = local.milan.location
  vpc_self_link = module.vpc.self_link

  ip_cidr_range               = "10.0.48.0/20"  # Range: 10.0.48.0 - 10.0.63.255
  cluster_secondary_ip_range  = "10.0.64.0/20"  # Range: 10.0.64.0 - 10.0.79.255
  services_secondary_ip_range = "10.0.80.0/20"  # Range: 10.0.80.0 - 10.0.95.255
}


# ====================
# GKE
# ====================
module "gke_virginia" {
  source     = "./modules/gke"
  depends_on = [module.vpc, module.subnet_virginia]

  name     = local.virginia.name
  location = local.virginia.location

  vpc    = module.vpc.name
  subnet = module.subnet_virginia.name

  cluster_secondary_range_name  = module.subnet_virginia.cluster_secondary_range_name
  services_secondary_range_name = module.subnet_virginia.services_secondary_range_name
}

module "gke_milan" {
  source     = "./modules/gke"
  depends_on = [module.vpc, module.subnet_milan]

  name     = local.milan.name
  location = local.milan.location

  vpc    = module.vpc.name
  subnet = module.subnet_milan.name

  cluster_secondary_range_name  = module.subnet_milan.cluster_secondary_range_name
  services_secondary_range_name = module.subnet_milan.services_secondary_range_name
}


# ====================
# Artifact Container Registry
# ====================
locals {
  artifact_app          = var.app
  artifact_location     = local.virginia.location
  artifact_repository   = "${var.app}-${terraform.workspace}"
  artifact_build_number = var.build
}

resource "google_service_account" "artifact_service_account" {
  project      = var.project
  account_id   = "artifact-registry-account"
  display_name = "Artifact Registry Service Account"
}

resource "google_project_iam_member" "artifact_service_account_iam_member" {
  depends_on = [google_service_account.artifact_service_account]

  project = var.project
  role    = "roles/artifactregistry.writer"
  member  = "serviceAccount:${google_service_account.artifact_service_account.email}"
}

resource "time_rotating" "artifact_service_account_key_rotation" {
  depends_on       = [google_project_iam_member.artifact_service_account_iam_member]
  rotation_minutes = 10
}

resource "google_service_account_key" "artifact_service_account_key" {
  depends_on = [time_rotating.artifact_service_account_key_rotation]

  service_account_id = google_service_account.artifact_service_account.id
  public_key_type    = "TYPE_X509_PEM_FILE"

  keepers = {
    rotation_time = time_rotating.artifact_service_account_key_rotation.rotation_rfc3339
  }
}


# ====================
# Build
# ====================
module "build" {
  depends_on = [google_service_account_key.artifact_service_account_key]
  source     = "./modules/build"

  project      = var.project
  app          = local.artifact_app
  repository   = local.artifact_repository
  build_number = local.artifact_build_number

  service_account_key_base64 = google_service_account_key.artifact_service_account_key.private_key
}


# ====================
# Deployment
# ====================
resource "google_service_account" "deployment_service_account" {
  project     = var.project
  account_id  = "deployment-service-account"
  description = "Deployment Service Account"
}

resource "google_project_iam_member" "deployment_service_account_iam_member" {
  depends_on = [google_service_account.artifact_service_account]

  project = var.project
  role    = "roles/container.developer"
  member  = "serviceAccount:${google_service_account.artifact_service_account.email}"
}

resource "time_rotating" "deployment_service_account_key_rotation" {
  depends_on       = [google_project_iam_member.deployment_service_account_iam_member]
  rotation_minutes = 10
}

resource "google_service_account_key" "deployment_service_account_key" {
  depends_on = [time_rotating.deployment_service_account_key_rotation]

  service_account_id = google_service_account.deployment_service_account.id
  public_key_type    = "TYPE_X509_PEM_FILE"

  keepers = {
    rotation_time = time_rotating.deployment_service_account_key_rotation.rotation_rfc3339
  }
}

provider "kubernetes" {
  alias = "virginia"

  host                   = "https://${module.gke_virginia.cluster_endpoint}"
  token                  = data.google_client_config.provider.access_token
  cluster_ca_certificate = base64decode(module.gke_virginia.cluster_ca_certificate)
}

module "deployment_virginia" {
  source     = "./modules/deployment"
  depends_on = [module.gke_virginia, module.build]

  providers = {
    kubernetes = kubernetes.virginia
  }

  project  = var.project
  name     = local.virginia.name
  location = local.virginia.location

  app          = local.artifact_app
  repository   = local.artifact_repository
  build_number = local.artifact_build_number

  service_account_key_base64 = google_service_account_key.deployment_service_account_key.private_key
}

provider "kubernetes" {
  alias = "milan"

  host                   = "https://${module.gke_milan.cluster_endpoint}"
  token                  = data.google_client_config.provider.access_token
  cluster_ca_certificate = base64decode(module.gke_milan.cluster_ca_certificate)
}

module "deployment_milan" {
  source     = "./modules/deployment"
  depends_on = [module.gke_milan, module.build]

  providers = {
    kubernetes = kubernetes.milan
  }

  project  = var.project
  name     = local.milan.name
  location = local.milan.location

  app          = local.artifact_app
  repository   = local.artifact_repository
  build_number = local.artifact_build_number

  service_account_key_base64 = google_service_account_key.deployment_service_account_key.private_key
}


# ====================
# Global Load Balancer
# ====================
module "global_load_balancer" {
  source     = ".modules/glb"
  depends_on = [module.deployment_virginia, module.deployment_milan]

  project = var.project
  name    = "global-load-balancer-${terraform.workspace}"

  vpc_self_link = module.vpc.self_link
  negs          = concat(module.deployment_virginia.negs, module.deployment_milan.negs)
}
