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

resource "azurerm_kubernetes_cluster" "kubernetes" {
  count   = local.kubernetes.name != "" ? 1 : 0

  name                = local.kubernetes.name
  dns_prefix          = local.kubernetes.name
  location            = var.location
  resource_group_name = var.resource_group_name
  node_resource_group = "${var.resource_group_name}-${local.kubernetes.name}"

  sku_tier                        = local.kubernetes.skuTier                   # Free, Paid
  automatic_upgrade_channel       = local.kubernetes.automaticChannelUpgrade   # none, patch, rapid, and stable
  private_cluster_enabled         = local.kubernetes.privateClusterEnabled

  api_server_access_profile {
    authorized_ip_ranges = local.kubernetes.masterAuthorizedNetworks
  }

  maintenance_window {
    dynamic "allowed" {
      for_each = local.kubernetes.maintenanceAllowed != null ? local.kubernetes.maintenanceAllowed : []
      content {
        day = allowed.value.day
        hours = allowed.value.hours
      }
    }

    dynamic "not_allowed" {
      for_each = local.kubernetes.maintenanceNotAllowed != null ? local.kubernetes.maintenanceNotAllowed : []
      content {
        start = not_allowed.value.start
        end = not_allowed.value.end
      }
    }
  }

  default_node_pool {
    name                   = local.kubernetes.nodePools[0].name
    vm_size                = local.kubernetes.nodePools[0].vmSize
    # os_type                = local.kubernetes.nodePools[0].osType
    orchestrator_version   = local.kubernetes.nodePools[0].orchestratorVersion
    host_encryption_enabled = local.kubernetes.nodePools[0].enableHostEncryption

    zones                  = local.kubernetes.nodePools[0].zones
    vnet_subnet_id         = local.kubernetes.networkPlugin == "azure" ? var.subnet_id : null

    auto_scaling_enabled   = local.kubernetes.nodePools[0].minNodeCount != local.kubernetes.nodePools[0].maxNodeCount
    node_count             = local.kubernetes.nodePools[0].minNodeCount
    min_count              = local.kubernetes.nodePools[0].minNodeCount != local.kubernetes.nodePools[0].maxNodeCount ? local.kubernetes.nodePools[0].minNodeCount : null
    max_count              = local.kubernetes.nodePools[0].minNodeCount != local.kubernetes.nodePools[0].maxNodeCount ? local.kubernetes.nodePools[0].maxNodeCount : null
  }

  network_profile {
    network_plugin     = local.kubernetes.networkPlugin
    network_policy     = local.kubernetes.networkPolicy
    load_balancer_sku  = "standard"
  }

  identity {
    type = "SystemAssigned"
  }

  /* Define if identity has not been defined
  service_principal {
    client_id     = azuread_application.kubernetes[count.index].application_id
    client_secret = azuread_service_principal_password.kubernetes[count.index].value
  }
  */

  # https://github.com/jcorioland/aks-rbac-azure-ad
  # https://www.danielstechblog.io/terraform-deploy-an-aks-cluster-using-managed-identity-and-managed-azure-ad-integration/
  # https://github.com/hashicorp/terraform-provider-azuread/issues/104
  dynamic "azure_active_directory_role_based_access_control" {
    for_each = local.kubernetes.rbacEnabled ? [ 1 ] : []
    content {
      tenant_id                = local.kubernetes.azureAdTenantId
      admin_group_object_ids   = coalesce(local.permissions.adminGroupObjectIds, [])
      azure_rbac_enabled       = local.kubernetes.azureRbacEnabled
    }
  }

  dynamic "oms_agent" {
    for_each = (local.kubernetes.omsAgentEnabled != null ? local.kubernetes.omsAgentEnabled : false) ? [ 1 ] : []
    content {
      log_analytics_workspace_id  = var.log_analytics_workspace_id
    }
  }

  dynamic "aci_connector_linux" {
    for_each = (local.kubernetes.aciEnabled != null ? local.kubernetes.aciEnabled : false) ? [ 1 ] : []
    content {
      subnet_name               = var.subnet_id  # TODO: ok?
    }
  }

  azure_policy_enabled = local.kubernetes.azurePolicyEnabled != null ? local.kubernetes.azurePolicyEnabled : false

  lifecycle {
    prevent_destroy = true
  }
}

resource "azurerm_kubernetes_cluster_node_pool" "pool" {
  for_each   = {for item in slice(local.kubernetes.nodePools, 1, length(local.kubernetes.nodePools)): item.name => item}

  name                   = each.value.name
  kubernetes_cluster_id  = azurerm_kubernetes_cluster.kubernetes[0].id
  vm_size                = each.value.vmSize
  os_type                = each.value.osType
  orchestrator_version   = each.value.orchestratorVersion
  host_encryption_enabled = each.value.enableHostEncryption

  zones                  = each.value.zones
  vnet_subnet_id         = local.kubernetes.networkPlugin == "azure" ? var.subnet_id : null

  auto_scaling_enabled   = each.value.minNodeCount != each.value.maxNodeCount
  node_count             = each.value.minNodeCount
  min_count              = each.value.minNodeCount != each.value.maxNodeCount ? each.value.minNodeCount : null
  max_count              = each.value.minNodeCount != each.value.maxNodeCount ? each.value.maxNodeCount : null
}
