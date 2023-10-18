# modules/kubernetes/main.tf

provider "kubernetes" {
  host                   = var.host
  token                  = var.token
  cluster_ca_certificate = base64decode(var.cluster_ca_certificate)
}

resource "kubernetes_secret" "registry_credentials" {
  metadata {
    name      = "registry-credentials"
    namespace = "default"
  }

  data = {
    ".dockerconfigjson" = jsonencode({
      "auths" = {
        "${var.artifact_location}-docker.pkg.dev" = {
          "username" = var.artifact_username
          "password" = var.artifact_password
        }
      }
    })
  }

  type = "kubernetes.io/dockerconfigjson"
}
#resource "kubernetes_deployment" "example_deployment" {
#  metadata {
#    name = "example-deployment"
#    labels = {
#      app = "example"
#    }
#  }
#
#  spec {
#    replicas = 3
#
#    selector {
#      match_labels = {
#        app = "example"
#      }
#    }
#
#    template {
#      metadata {
#        labels = {
#          app = "example"
#        }
#      }
#
#      spec {
#        image_pull_secrets {
#          name = kubernetes_secret.registry_credentials.metadata[0].name
#        }
#
#        container {
#          image = "your-registry-url/your-image:your-tag"
#          name  = "example-container"
#        }
#      }
#    }
#  }
#}
