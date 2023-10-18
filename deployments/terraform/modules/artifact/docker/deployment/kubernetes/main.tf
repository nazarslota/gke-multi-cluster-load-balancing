# modules/kubernetes/main.tf

terraform {
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
  }
}

resource "kubernetes_namespace" "namespace" {
  metadata {
    annotations = {
      name = var.name
    }

    name = var.name
  }
}

resource "kubernetes_secret" "registry_credentials" {
  metadata {
    name      = "${var.name}-registry-credentials"
    namespace = kubernetes_namespace.namespace.metadata.0.name
  }

  data = {
    ".dockerconfigjson" = jsonencode({
      "auths" = {
        "${var.artifact_location}-docker.pkg.dev" = {
          "username" = "_json_key_base64"
          "password" = var.artifact_service_account_key_base64
        }
      }
    })
  }

  type = "kubernetes.io/dockerconfigjson"

  depends_on = [
    kubernetes_namespace.namespace
  ]
}

resource "kubernetes_deployment" "deployment" {
  metadata {
    name   = "${var.name}-deployment"
    labels = {
      app = "${var.name}-deployment"
    }

    namespace = kubernetes_namespace.namespace.metadata.0.name
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "${var.name}-deployment"
      }
    }

    template {
      metadata {
        labels = {
          app = "${var.name}-deployment"
        }
      }

      spec {
        image_pull_secrets {
          name = kubernetes_secret.registry_credentials.metadata.0.name
        }

        container {
          name  = "${var.name}-container"
          image = "quay.io/stepanstipl/k8s-demo-app:latest"
          # "${var.artifact_location}-docker.pkg.dev/${var.project}/${var.artifact_repository}/${var.artifact_application}:${var.artifact_build_number}"
        }
      }
    }
  }

  timeouts {
    create = "5m"
    update = "5m"
  }

  depends_on = [
    kubernetes_secret.registry_credentials
  ]
}
