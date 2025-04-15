locals {
  backend_services = {
    overworld       = var.overworld_backend_version
    bugfinder       = var.bugfinder_backend_version
    chickenshock    = var.chickenshock_backend_version
    crosswordpuzzle = var.crosswordpuzzle_backend_version
    finitequiz      = var.finitequiz_backend_version
    memory          = var.memory_backend_version
    regexgame       = var.regexgame_backend_version
    towercrush      = var.towercrush_backend_version
    towerdefense    = var.towerdefense_backend_version
  }
}

resource "kubernetes_service" "backend" {
  for_each = local.backend_services
  metadata {
    name = "gamify-it-${each.key}-backend"
    labels = {
      "gamify-it.app" = "${each.key}-backend"
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
      "gamify-it.app" = "${each.key}-backend"
    }
  }
}

resource "kubernetes_deployment" "backend" {
  for_each   = local.backend_services
  depends_on = [helm_release.postgres_db]
  metadata {
    name = "gamify-it-${each.key}-backend"
    labels = {
      "gamify-it.app" = "${each.key}-backend"
    }
    namespace = kubernetes_namespace.gamify-it.metadata[0].name
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        "gamify-it.app" = "${each.key}-backend"
      }
    }

    template {
      metadata {
        labels = {
          "gamify-it.app" = "${each.key}-backend"
        }
      }

      spec {
        container {
          name              = "gamify-it-${each.key}-backend"
          image             = "ghcr.io/gamify-it/${each.key}-backend:${coalesce(each.value, var.gamify-it_version)}"
          image_pull_policy = "Always"


          env {
            name  = "BUGFINDER_URL"
            value = "http://gamify-it-bugfinder-backend/api/v1"
          }

          env {
            name  = "CHICKENSHOCK_URL"
            value = "http://gamify-it-chickenshock-backend/api/v1"
          }

          env {
            name  = "CROSSWORDPUZZLE_URL"
            value = "http://gamify-it-crosswordpuzzle-backend/api/v1"
          }

          env {
            name  = "FINITEQUIZ_URL"
            value = "http://gamify-it-finitequiz-backend/api/v1"
          }

          env {
            name  = "OVERWORLD_URL"
            value = "http://gamify-it-overworld-backend/api/v1"
          }

          env {
            name  = "POSTGRES_USER"
            value = "postgres"
          }

          env {
            name  = "POSTGRES_URL"
            value = "postgresql://gamify-it-${each.key}-db:5432/postgres"
          }

          env {
            name = "POSTGRES_PASSWORD"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.postgres_password_secret[each.key].metadata[0].name
                key  = "password"
              }
            }
          }

          env {
            name  = "KEYCLOAK_URL"
            value = "http://gamify-it-keycloak/keycloak/realms/Gamify-IT"
          }

          env {
            name  = "KEYCLOAK_ISSUER"
            value = "${var.endpoint}/keycloak/realms/Gamify-IT"
          }
        }
      }
    }
  }
}
