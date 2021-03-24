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

provider "azurerm" {
  features {}
}

locals {
  kubernetes               = var.kubernetes
  permissions              = var.permissions
  postgresqlClusterNames   = var.use_kubernetes_as_db_proxy ? var.postgresql_cluster_names : []
  mysqlClusterNames        = var.use_kubernetes_as_db_proxy ? var.mysql_cluster_names : []

  helmEnabled              = var.helm_enabled

  nodePools = (
    local.kubernetes.nodePools != null
    ? local.kubernetes.nodePools
    : []
  )

  ingressNginxControllers = (
    local.kubernetes.ingressNginxControllers != null
    ? local.kubernetes.ingressNginxControllers
    : []
  )
}
