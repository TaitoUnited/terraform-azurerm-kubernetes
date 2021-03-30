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

data "azurerm_private_endpoint_connection" "postgresql" {
  for_each            = {for item in (local.helmEnabled ? local.postgresqlClusterNames : []): item => item}
  resource_group_name = var.resource_group_name
  name                = "${each.value}-endpoint"
}

data "azurerm_private_endpoint_connection" "mysql" {
  for_each            = {for item in (local.helmEnabled ? local.mysqlClusterNames : []): item => item}
  resource_group_name = var.resource_group_name
  name                = "${each.value}-endpoint"
}

resource "helm_release" "postgres_proxy" {
  depends_on = [azurerm_kubernetes_cluster.kubernetes, module.helm_apps]

  for_each   = {for item in (local.helmEnabled ? local.postgresqlClusterNames : []): item => item}
  name       = each.value
  namespace  = "db-proxy"
  create_namespace = true
  repository = "https://isotoma.github.io/charts/"
  chart      = "socat-tunneller"
  version    = var.socat_tunneler_version
  wait       = false

  set {
    name  = "tunnel.host"
    value = data.azurerm_private_endpoint_connection.postgresql[each.key].private_service_connection[0].private_ip_address
  }

  set {
    name  = "tunnel.port"
    value = 5432
  }
}

resource "helm_release" "mysql_proxy" {
  depends_on = [azurerm_kubernetes_cluster.kubernetes, helm_release.postgres_proxy]

  for_each   = {for item in (local.helmEnabled ? local.mysqlClusterNames : []): item => item}
  name       = each.value
  namespace  = "db-proxy"
  repository = "https://isotoma.github.io/charts/"
  chart      = "socat-tunneller"
  version    = var.socat_tunneler_version
  wait       = false

  set {
    name  = "tunnel.host"
    value = data.azurerm_private_endpoint_connection.mysql[each.key].private_service_connection[0].private_ip_address
  }

  set {
    name  = "tunnel.port"
    value = 3306
  }
}
