provider "kubernetes" {
  config_path = var.kubeconfig
}

provider "helm" {
  kubernetes {
    config_path = var.kubeconfig
  }
}

resource "kubernetes_namespace" "gamify-it" {
  metadata {
    name = var.namespace
  }
}
