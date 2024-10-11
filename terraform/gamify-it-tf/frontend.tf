locals {
  frontend_services = {
    overworld                    = var.overworld_version
    "landing-page"               = var.landing_page_version
    "lecturer-interface"         = var.lecturer_interface_version
    "privacy-policy"             = var.privacy_policy_version
    "third-party-license-notice" = var.third_party_license_notice_version
    bugfinder                    = var.bugfinder_version
    chickenshock                 = var.chickenshock_version
    crosswordpuzzle              = var.crosswordpuzzle_version
    finitequiz                   = var.finitequiz_version
    memory                       = var.memory_version
    regexgame                    = var.regexgame_version
    towercrush                   = var.towercrush_version
    "tower-defense"              = var.towerdefense_version
  }
}

resource "kubernetes_service" "frontend" {
  for_each = local.frontend_services
  metadata {
    name = "gamify-it-${each.key}"
    labels = {
      "gamify-it.app" = each.key
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
      "gamify-it.app" = each.key
    }
  }
}

resource "kubernetes_deployment" "frontend" {
  for_each = local.frontend_services
  metadata {
    name = "gamify-it-${each.key}"
    labels = {
      "gamify-it.app" = each.key
    }
    namespace = kubernetes_namespace.gamify-it.metadata[0].name
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        "gamify-it.app" = each.key
      }
    }

    template {
      metadata {
        labels = {
          "gamify-it.app" = each.key
        }
      }

      spec {
        container {
          name              = "gamify-it-${each.key}"
          image             = "ghcr.io/gamify-it/${each.key}:${coalesce(each.value, var.gamify-it_version)}"
          image_pull_policy = "Always"
        }
      }
    }
  }
}
