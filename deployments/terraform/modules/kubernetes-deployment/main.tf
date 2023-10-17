# modules/kubernetes-deployment/main.tf

# modules/kubernetes-deployment/main.tf

provider "kubernetes" {
  host                   = var.host
  token                  = var.token
  cluster_ca_certificate = base64decode(var.cluster_ca_certificate)
}

resource "kubernetes_secret" "registry_credentials" {
  metadata {
    name = "registry-credentials"
  }

  data {
    ".dockerconfigjson" = filebase64("${path.module}/.dockerconfigjson")
  }

  type = "kubernetes.io/dockerconfigjson"
}

resource "kubernetes_deployment" "example_deployment" {
  metadata {
    name = "example-deployment"
    labels = {
      app = "example"
    }
  }

  spec {
    replicas = 3

    selector {
      match_labels = {
        app = "example"
      }
    }

    template {
      metadata {
        labels = {
          app = "example"
        }
      }

      spec {
        image_pull_secrets {
          name = kubernetes_secret.registry_credentials.metadata[0].name
        }

        container {
          image = "your-registry-url/your-image:your-tag"
          name  = "example-container"
        }
      }
    }
  }
}

# ... rest of your configuration
