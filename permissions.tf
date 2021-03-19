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

# Kubernetes: container registry pull permission

resource "random_uuid" "kubernetes_acrpull_id" {
  count                = local.kubernetes.name != "" ? 1 : 0
  keepers = {
    acr_id  = azurerm_container_registry.acr.id
    sp_id   = azurerm_kubernetes_cluster.kubernetes.kubelet_identity[0].object_id
    role    = "AcrPull"
  }
}

resource "azurerm_role_assignment" "kubernetes_acrpull" {
  count                = local.kubernetes.name != "" ? 1 : 0

  principal_id         = azurerm_kubernetes_cluster.kubernetes.kubelet_identity[0].object_id
  name                 = random_uuid.kubernetes_acrpull_id[count.index].result
  scope                = azurerm_container_registry.acr.id
  role_definition_name = "AcrPull"
  # skip_service_principal_aad_check = true
}

# Kubernetes: monitoring permission

resource "random_uuid" "kubernetes_monitoring_id" {
  count                = local.kubernetes.name != "" ? 1 : 0
  keepers = {
    sp_id   = azurerm_kubernetes_cluster.kubernetes.identity[0].principal_id
    role    = "Monitoring Metrics Publisher"
  }
}

resource "azurerm_role_assignment" "kubernetes_monitoring" {
  principal_id         = azurerm_kubernetes_cluster.kubernetes.identity[0].principal_id
  name                 = random_uuid.kubernetes_monitoring_id[count.index].result
  scope                = azurerm_kubernetes_cluster.kubernetes.id
  role_definition_name = "Monitoring Metrics Publisher"
}

# Kubernetes: network permission

resource "random_uuid" "kubernetes_network_id" {
  count                = local.kubernetes.name != "" ? 1 : 0
  keepers = {
    sp_id   = azurerm_kubernetes_cluster.kubernetes.identity[0].principal_id
    role    = "Network Contributor"
  }
}

resource "azurerm_role_assignment" "kubernetes_network" {
  count                = local.kubernetes.name != "" ? 1 : 0

  principal_id         = azurerm_kubernetes_cluster.kubernetes.identity[0].principal_id
  name                 = random_uuid.kubernetes_network_id[count.index].result
  scope                = var.subnet_id
  role_definition_name = "Network Contributor"
  # skip_service_principal_aad_check = true
}

/* TODO: not needed anymore?

# Owners: kubernetes admin permission

resource "random_uuid" "owner_kubeadmin_id" {
  for_each             = {for item in (local.kubernetes.name != "" ? length(local.permissions.admins) : []) : item.id => item}
  keepers = {
    acr_id  = azurerm_container_registry.acr.id
    sp_id   = each.value.id
    role    = "Azure Kubernetes Service Cluster Admin Role"
  }
}

resource "azurerm_role_assignment" "owner_kubeadmin" {
  for_each             = {for item in (local.kubernetes.name != "" ? length(local.permissions.admins) : []) : item.id => item}

  principal_id         = each.value.id
  name                 = random_uuid.owner_kubeadmin_id[each.key].result
  scope                = azurerm_kubernetes_cluster.kubernetes[0].id
  role_definition_name = "Azure Kubernetes Service Cluster Admin Role"
}

# Developers: kubernetes user permission

resource "random_uuid" "developer_kubeuser_id" {
  for_each             = {for item in (local.kubernetes.name != "" ? length(local.permissions.users) : []) : item.id => item}
  keepers = {
    acr_id  = azurerm_container_registry.acr.id
    sp_id   = each.value
    role    = "Azure Kubernetes Service Cluster User Role"
  }
}

resource "azurerm_role_assignment" "developer_kubeuser" {
  for_each             = {for item in (local.kubernetes.name != "" ? length(local.permissions.users) : []) : item.id => item}

  principal_id         = each.value
  name                 = random_uuid.developer_kubeuser_id[each.key].result
  scope                = azurerm_kubernetes_cluster.kubernetes[0].id
  role_definition_name = "Azure Kubernetes Service Cluster User Role"
}

*/
