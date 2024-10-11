resource "kubernetes_service" "reverse_proxy" {
  metadata {
    name = "gamify-it-reverse-proxy"
    labels = {
      "gamify-it.app" = "reverse-proxy"
    }
    namespace = kubernetes_namespace.gamify-it.metadata[0].name
  }

  spec {
    port {
      name        = "80"
      port        = 80
      target_port = 80
    }

    selector = {
      "gamify-it.app" = "reverse-proxy"
    }
  }
}

resource "kubernetes_deployment" "reverse_proxy" {
  metadata {
    name = "gamify-it-reverse-proxy"
    labels = {
      "gamify-it.app" = "reverse-proxy"
    }
    namespace = kubernetes_namespace.gamify-it.metadata[0].name
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        "gamify-it.app" = "reverse-proxy"
      }
    }

    template {
      metadata {
        labels = {
          "gamify-it.app" = "reverse-proxy"
        }
      }

      spec {
        container {
          name              = "gamify-it-reverse-proxy"
          image             = "ghcr.io/gamify-it/reverse-proxy:${coalesce(var.reverse_proxy_version, var.gamify-it_version)}"
          image_pull_policy = "Always"


          env {
            name  = "SERVICES"
            value = "default keycloak bugfinder chickenshock crosswordpuzzle fileserver finitequiz memory regexgame towercrush"
          }

          env {
            name  = "SSL_ENABLED"
            value = "false"
          }

          env {
            name  = "LOCAL_DOMAIN"
            value = ".${kubernetes_namespace.gamify-it.metadata[0].name}.svc.cluster.local"
          }

          env {
            name  = "DNS_NAMESERVER"
            value = "kube-dns.kube-system.svc.cluster.local"
          }
        }
      }
    }
  }
}
