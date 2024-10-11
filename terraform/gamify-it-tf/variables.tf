variable "namespace" {
  type        = string
  description = "The k8s namespace to deploy the application in"
  default     = "gamify-it"
}

variable "endpoint" {
  type        = string
  description = "The endpoint where the application is reachable"
  default     = "http://localhost"
}

variable "enable_ingress" {
  type        = bool
  description = "Whether to enable the ingress, only relevant if endpoint starts with https://"
  default     = false
}

variable "kubeconfig" {
  type        = string
  description = "The kubeconfig file to use for kubectl"
  default     = "./kubeconfig.yaml"
}

variable "keycloak_admin_password" {
  type        = string
  description = "The password for the keycloak admin user"
  default     = "admin"
}

variable "storage_class" {
  type        = string
  description = "The storage class to use for all volumes, if null the default storage class is used"
  default     = null
}



variable "keycloak_version" {
  type        = string
  description = "The version of the keycloak image to use"
  default     = "26"
}

variable "gamify-it_version" {
  type        = string
  description = "The version of the gamify-it image to use"
  default     = "latest"
}

variable "reverse_proxy_version" {
  type        = string
  description = "The version of the reverse proxy image to use"
  nullable    = true
  default     = null
}

variable "bugfinder_version" {
  type        = string
  description = "The version of the bugfinder image to use"
  nullable    = true
  default     = null
}

variable "bugfinder_backend_version" {
  type        = string
  description = "The version of the bugfinder backend image to use"
  nullable    = true
  default     = null
}

variable "chickenshock_version" {
  type        = string
  description = "The version of the chickenshock image to use"
  nullable    = true
  default     = null
}

variable "chickenshock_backend_version" {
  type        = string
  description = "The version of the chickenshock backend image to use"
  nullable    = true
  default     = null
}

variable "crosswordpuzzle_version" {
  type        = string
  description = "The version of the crosswordpuzzle image to use"
  nullable    = true
  default     = null
}

variable "crosswordpuzzle_backend_version" {
  type        = string
  description = "The version of the crosswordpuzzle backend image to use"
  nullable    = true
  default     = null
}

variable "fileserver_version" {
  type        = string
  description = "The version of the fileserver image to use"
  nullable    = true
  default     = null
}

variable "fileserver_backend_version" {
  type        = string
  description = "The version of the fileserver backend image to use"
  nullable    = true
  default     = null
}

variable "finitequiz_version" {
  type        = string
  description = "The version of the finitequiz image to use"
  nullable    = true
  default     = null
}

variable "finitequiz_backend_version" {
  type        = string
  description = "The version of the finitequiz backend image to use"
  nullable    = true
  default     = null
}

variable "memory_version" {
  type        = string
  description = "The version of the memory image to use"
  nullable    = true
  default     = null
}

variable "memory_backend_version" {
  type        = string
  description = "The version of the memory backend image to use"
  nullable    = true
  default     = null
}

variable "regexgame_version" {
  type        = string
  description = "The version of the regexgame image to use"
  nullable    = true
  default     = null
}

variable "regexgame_backend_version" {
  type        = string
  description = "The version of the regexgame backend image to use"
  nullable    = true
  default     = null
}

variable "towercrush_version" {
  type        = string
  description = "The version of the towercrush image to use"
  nullable    = true
  default     = null
}

variable "towercrush_backend_version" {
  type        = string
  description = "The version of the towercrush backend image to use"
  nullable    = true
  default     = null
}

variable "towerdefense_version" {
  type        = string
  description = "The version of the towerdefense image to use"
  nullable    = true
  default     = null
}

variable "towerdefense_backend_version" {
  type        = string
  description = "The version of the towerdefense backend image to use"
  nullable    = true
  default     = null
}

variable "overworld_version" {
  type        = string
  description = "The version of the overworld image to use"
  nullable    = true
  default     = null
}

variable "overworld_backend_version" {
  type        = string
  description = "The version of the overworld backend image to use"
  nullable    = true
  default     = null
}

variable "landing_page_version" {
  type        = string
  description = "The version of the landing page image to use"
  nullable    = true
  default     = null
}

variable "lecturer_interface_version" {
  type        = string
  description = "The version of the lecturer interface image to use"
  nullable    = true
  default     = null
}

variable "privacy_policy_version" {
  type        = string
  description = "The version of the privacy policy image to use"
  nullable    = true
  default     = null
}

variable "third_party_license_notice_version" {
  type        = string
  description = "The version of the third party license notice image to use"
  nullable    = true
  default     = null
}
