/**
 * Copyright 2021 Taito United
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

variable "name" {
  type        = string
}

variable "resource_group_name" {
  type        = string
}

variable "location" {
  type        = string
}

variable "log_analytics_workspace_id" {
  type        = string
  default     = ""
}

variable "email" {
  type        = string
  description = "DevOps support email"
}

variable "subnet_id" {
  type        = string
}

# Use optional and defaults? https://www.terraform.io/docs/language/functions/defaults.html
variable "kubernetes" {
  type = object({
    name = string
    skuTier = string # Paid, Free
    automaticChannelUpgrade = string # none, patch, rapid, and stable
    # Network
    networkPlugin = string
    networkPolicy = optional(string)
    privateClusterEnabled = bool
    masterAuthorizedNetworks = list(string)
    # RBAC
    rbacEnabled = bool
    azureAdTenantId = optional(string)
    azureAdManaged = bool
    clientAppId = optional(string)
    serverAppId = optional(string)
    serverAppSecret = optional(string)
    # Monitoring
    omsAgentEnabled = optional(bool)
    # Add-ons
    aciEnabled = optional(bool)
    azurePolicyEnabled = optional(bool)
    nodePools = list(object({
      name = string
      vmSize = string
      osType = optional(string)
      orchestratorVersion = optional(string)
      enableHostEncryption = optional(bool)
      availabilityZones = list(string)
      minNodeCount = number
      maxNodeCount = number
    }))
    ingressNginxControllers = optional(list(object({
      name = string
      class = string
      replicas = number
      metricsEnabled = optional(bool)
      maxmindLicenseKey = optional(string)
      configMap = map(string)
      tcpServices = map(string)
      udpServices = map(string)
    })))
    certManager = optional(object({
      enabled = bool
    }))
  })
  description = "Resources as JSON (see README.md). You can read values from a YAML file with yamldecode()."
}

variable "permissions" {
  type = object({
    adminGroupObjectIds = optional(list(string))
    clusterRoles = optional(list(object({
      name = string
      subjects = list(string)
    })))
    namespaces = optional(list(object({
      name = string
      clusterRoles = list(object({
        name = string
        subjects = list(string)
      }))
    })))
  })
  description = "Resources as JSON (see README.md). You can read values from a YAML file with yamldecode()."
}

# Helm infrastructure apps

variable "helm_enabled" {
  type        = bool
  default     = "false"
  description = "Installs helm apps if set to true. Should be set to true only after Kubernetes cluster already exists."
}

variable "generate_ingress_dhparam" {
  type        = bool
  description = "Generate Diffie-Hellman key for ingress"
}

variable "use_kubernetes_as_db_proxy" {
  type        = bool
  default     = false
}

variable "postgresql_cluster_names" {
  type        = list(string)
  default     = []
  description = "Resources as JSON (see README.md). You can read values from a YAML file with yamldecode()."
}

variable "mysql_cluster_names" {
  type        = list(string)
  default     = []
  description = "Resources as JSON (see README.md). You can read values from a YAML file with yamldecode()."
}

# Helm app versions

# NOTE: Remember to update also helm_apps.tf
# TODO: Should be optional and null by default
variable "ingress_nginx_version" {
  type        = string
  default     = "3.24.0"
}

# NOTE: Remember to update also helm_apps.tf
# TODO: Should be optional and null by default
variable "cert_manager_version" {
  type        = string
  default     = "1.2.0"
}

variable "kubernetes_admin_version" {
  type        = string
  default     = "1.8.0"
}

variable "socat_tunneler_version" {
  type        = string
  default     = "0.1.0"
}
