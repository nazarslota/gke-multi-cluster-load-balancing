# modules/kubernetes-deploy/main.tf

provider "kubernetes" {
  host                   = var.host
  token                  = var.token
  cluster_ca_certificate = base64decode(var.cluster_ca_certificate)
}

resource "kubernetes_deployment" "" {}
