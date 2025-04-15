resource "random_password" "keycloak_db_password" {
  length  = 32
  special = false
}

resource "helm_release" "keycloak" {
  name       = "keycloak"
  repository = "oci://registry-1.docker.io/bitnamicharts"
  chart      = "keycloak"
  namespace  = kubernetes_namespace.gamify-it.metadata[0].name
  depends_on = [kubernetes_config_map.keycloak_realm_config]

  values = [
    <<-EOF
    fullnameOverride: "gamify-it-keycloak"
    image:
      tag: "${var.keycloak_version}"
    extraEnvVars:
      - name: "KEYCLOAK_EXTRA_ARGS"
        value: "--import-realm"
      - name: "KEYCLOAK_HOSTNAME"
        value: "${var.endpoint}/keycloak"
      - name: "KEYCLOAK_ADMIN_HOSTNAME"
        value: "${var.endpoint}/keycloak"
    auth:
      adminUser: admin
      adminPassword: ${var.keycloak_admin_password}
    proxy: "edge"
    production: true
    postgresql:
      auth:
        username: "gamify-it"
        password: "${random_password.keycloak_db_password.result}"
        database: "gamify-it"
    httpRelativePath: "/keycloak/"
    metrics:
      enabled: true
    extraVolumes:
      - name: gamify-it-keycloak-realm
        configMap:
           name: gamify-it-keycloak-realm-config
    extraVolumeMounts:
      - name: gamify-it-keycloak-realm
        mountPath: "/opt/bitnami/keycloak/data/import"
    EOF
  ]

  dynamic "set" {
    for_each = var.storage_class != null ? [var.storage_class] : []
    content {
      name  = "global.defaultStorageClass"
      value = set.value
    }
  }
}

resource "kubernetes_config_map" "keycloak_realm_config" {
  metadata {
    name      = "gamify-it-keycloak-realm-config"
    namespace = kubernetes_namespace.gamify-it.metadata[0].name
  }

  data = {
    "gamify-it-realm.json" = file("files/keycloak-realm-template.json")
  }
}
