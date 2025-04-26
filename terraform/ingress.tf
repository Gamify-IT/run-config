locals {
  gamify_it_host = regex("(https?://)?([^/]+)", var.endpoint)[1]
}

resource "kubernetes_ingress_v1" "ingress" {
  count = var.endpoint != "" && startswith(var.endpoint, "https://") && var.enable_ingress ? 1 : 0

  metadata {
    name      = "ingress"
    namespace = kubernetes_namespace.gamify-it.metadata[0].name
    annotations = {
      "cert-manager.io/cluster-issuer" : "letsencrypt-production"
      "kubernetes.io/ingress.class" : "nginx"
    }
  }

  spec {
    default_backend {
      service {
        name = kubernetes_service.reverse_proxy.metadata[0].name
        port {
          number = 80
        }
      }
    }

    rule {

      host = local.gamify_it_host
      http {
        path {
          backend {
            service {
              name = kubernetes_service.reverse_proxy.metadata[0].name
              port {
                number = 80
              }
            }
          }
          path = "/"
        }
      }
    }

    tls {
      hosts       = [local.gamify_it_host]
      secret_name = "${local.gamify_it_host}-tls"
    }
  }
}
