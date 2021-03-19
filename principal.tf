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

/* TODO: NOT NEEDED ANYMORE?

resource "azuread_application" "kubernetes" {
  count                      = local.kubernetes.name != "" ? 1 : 0

  name                       = "${var.name}-${local.kubernetes.name}"
  identifier_uris            = ["http://${local.kubernetes.name}.${var.name}"]
  available_to_other_tenants = false
  oauth2_allow_implicit_flow = false
}

resource "azuread_service_principal" "kubernetes" {
  count   = local.kubernetes.name != "" ? 1 : 0

  application_id = azuread_application.kubernetes[count.index].application_id
  tags = ["aks", "kubernetes", "terraform", local.kubernetes.name, var.name]
}

resource "random_string" "kubernetes_password" {
  count   = local.kubernetes.name != "" ? 1 : 0

  length  = 32
  special = false
  upper   = true

  keepers = {
    service_principal = azuread_service_principal.kubernetes[count.index].id
  }
}

resource "azuread_service_principal_password" "kubernetes" {
  count                = local.kubernetes.name != "" ? 1 : 0

  service_principal_id = azuread_service_principal.kubernetes[count.index].id
  value                = random_string.kubernetes_password[count.index].result
  end_date_relative    = "8760h"  # one year
}

*/
