# modules/artifact/docker/deployment/kubernetes/main.tf

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
        "${var.location}-docker.pkg.dev" = {
          "username" = "_json_key_base64"
          "password" = var.service_account_key_base64
        }
      }
    })
  }

  type = "kubernetes.io/dockerconfigjson"

  depends_on = [
    kubernetes_namespace.namespace
  ]
}

locals {
  deployment_name = "${var.name}-deployment"
}

resource "kubernetes_deployment" "deployment" {
  metadata {
    name   = local.deployment_name
    labels = {
      app = local.deployment_name
    }

    namespace = kubernetes_namespace.namespace.metadata.0.name
  }

  spec {
    replicas = 6

    selector {
      match_labels = {
        app = local.deployment_name
      }
    }

    template {
      metadata {
        labels = {
          app = local.deployment_name
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

resource "kubernetes_service" "neg" {
  metadata {
    name        = "${var.name}-neg"
    annotations = {
      "cloud.google.com/neg" = jsonencode({
        "ingress" : true,
        "exposed_ports" : {
          "8080" : {}
        }
      })
    }
    namespace = kubernetes_namespace.namespace.metadata.0.name
  }

  spec {
    selector = {
      app = local.deployment_name
    }

    port {
      protocol    = "TCP"
      port        = 8080
      target_port = 8080
    }

    type = "ClusterIP"
  }

  depends_on = [
    kubernetes_deployment.deployment
  ]
}

resource "time_sleep" "wait_neg" {
  create_duration = "3m"

  triggers = {
    always_run     = timestamp()
    neg_service_id = kubernetes_service.neg.id
  }

  depends_on = [
    kubernetes_service.neg
  ]
}

resource "null_resource" "get_negs" {
  provisioner "local-exec" {
    command = <<EOL
      rm -f ${path.module}/neg.json
      echo ${jsonencode(kubernetes_service.neg.metadata.0.annotations["cloud.google.com/neg-status"])} >> ${path.module}/neg.json
    EOL
  }

  triggers = {
    always_run     = timestamp()
    neg_service_id = kubernetes_service.neg.id
  }

  depends_on = [
    time_sleep.wait_neg
  ]
}

data "local_file" "negs" {
  filename   = "${path.module}/neg.json"
  depends_on = [
    null_resource.get_negs
  ]
}

