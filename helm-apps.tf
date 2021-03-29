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

module "helm_apps" {
  source                      = "TaitoUnited/infrastructure-apps/helm"
  version                     = "2.1.1" # NOTE: Remember to update also variables.tf

  depends_on                  = [azurerm_kubernetes_cluster.kubernetes]
  count                       = local.helmEnabled ? 1 : 0

  generate_ingress_dhparam    = var.generate_ingress_dhparam
  ingress_nginx_version       = var.ingress_nginx_version
  cert_manager_version        = var.cert_manager_version

  pod_security_policy_enabled = local.kubernetes.azurePolicyEnabled  # TODO: ok?
  # TODO: ingressNginxLoadBalancerIPs = google_compute_address.kubernetes_ingress.*.address
  email                       = var.email

  resources                   = local.kubernetes
}
