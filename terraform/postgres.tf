locals {
  db_services = toset(["overworld", "bugfinder", "chickenshock", "crosswordpuzzle", "finitequiz", "memory", "regexgame", "towercrush", "towerdefense"])
}

resource "random_password" "postgres_password" {
  for_each = local.db_services
  length   = 32
  special  = false
}

resource "kubernetes_secret" "postgres_password_secret" {
  for_each = local.db_services
  metadata {
    name      = "postgres-password-${each.key}"
    namespace = kubernetes_namespace.gamify-it.metadata[0].name
  }

  data = {
    password = random_password.postgres_password[each.key].result
  }
}

resource "helm_release" "postgres_db" {
  for_each   = local.db_services
  name       = "gamify-it-${each.key}-db"
  repository = "oci://registry-1.docker.io/bitnamicharts"
  chart      = "postgresql"
  namespace  = kubernetes_namespace.gamify-it.metadata[0].name

  set {
    name  = "fullnameOverride"
    value = "gamify-it-${each.key}-db"
  }

  set {
    name  = "global.postgresql.auth.database"
    value = "gropius"
  }

  dynamic "set" {
    for_each = var.storage_class != null ? [var.storage_class] : []
    content {
      name  = "global.defaultStorageClass"
      value = set.value
    }
  }

  set {
    name  = "postgres.auth.enablePostgresUser"
    value = "false"
  }

  set {
    name  = "global.postgresql.auth.username"
    value = "postgres"
  }

  set {
    name  = "global.postgresql.auth.password"
    value = random_password.postgres_password[each.key].result
  }
}
