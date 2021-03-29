# Azure Kubernetes

Example usage:

```
provider "azurerm" {
  features {}
}

module "kubernetes" {
  source                     = "TaitoUnited/kubernetes/azurerm"
  version                    = "1.0.0"

  name                       = "my-infrastructure"
  resource_group_name        = "my-infrastructure"
  location                   = "northeurope"
  email                      = "devops@mydomain.com"
  log_analytics_workspace_id = module.monitoring.log_analytics_workspace_id

  # Network
  subnet_id                  = module.network.internal_subnet_id

  # Permissions
  permissions                = yamldecode(
    file("${path.root}/../infra.yaml")
  )["permissions"]

  # Kubernetes
  kubernetes                 = yamldecode(
    file("${path.root}/../infra.yaml")
  )["kubernetes"]

  # Helm infrastructure apps
  helm_enabled               = false  # Should be false on the first run, then true
  generate_ingress_dhparam   = false
  use_kubernetes_as_db_proxy = true
  postgresql_cluster_names   = [ "my-postgresql-1" ]
  mysql_cluster_names        = [ "my-mysql-1" ]
}
```

Example YAML:

```
# Permissions
permissions:
  adminGroupObjectIds: [ "1234567a-123b-123c-123d-1e2345a6c7e8" ]
  clusterRoles:
    - name: taito-iam-admin
      subjects: [ "group:TODO" ]
    - name: taito-status-viewer
      subjects: [ "group:TODO" ]
  namespaces:
    - name: db-proxy
      clusterRoles:
        - name: taito-pod-portforwarder
          subjects: [ "user:TODO" ]
    - name: my-namespace
      clusterRoles:
        - name: taito-status-viewer
          subjects: [ "user:TODO" ]
    - name: another-namespace
      clusterRoles:
        - name: taito-developer
          subjects: [ "user:TODO" ]

# For Kubernetes setting descriptions, see
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster_node_pool
kubernetes:
  name: zone1-common-kube1
  skuTier: Free  # Free, Paid
  automaticChannelUpgrade: stable  # none, patch, rapid, stable

  # Network
  networkPlugin: azure  # azure, kubenet
  networkPolicy: azure  # azure, calico
  privateClusterEnabled: false
  masterAuthorizedNetworks:
    - 0.0.0.0/0

  # RBAC
  rbacEnabled: false
  azureAdManaged: false

  # Monitoring
  omsAgentEnabled: true

  # Add-ons
  aciEnabled: false
  azurePolicyEnabled: false

  # Node pools
  nodePools:
    - name: default
      vmSize: Standard_D2_v2
      availabilityZones: [ "1", "2", "3" ]
      minNodeCount: 3
      maxNodeCount: 3

  # Certificate managers
  certManager:
    enabled: true

  # Ingress controllers
  ingressNginxControllers:
    - name: ingress-nginx
      class: nginx
      replicas: 3
      metricsEnabled: true
      # MaxMind license key for GeoIP2: https://support.maxmind.com/account-faq/license-keys/how-do-i-generate-a-license-key/
      maxmindLicenseKey:
      # Map TCP/UDP connections to services
      tcpServices:
        3000: my-namespace/my-tcp-service:9000
      udpServices:
        3001: my-namespace/my-udp-service:9001
      # See https://kubernetes.github.io/ingress-nginx/user-guide/nginx-configuration/configmap/
      configMap:
        # Hardening
        # See https://kubernetes.github.io/ingress-nginx/deploy/hardening-guide/
        keep-alive: 10
        custom-http-errors: 403,404,503,500
        server-snippet: >
          location ~ /\.(?!well-known).* {
            deny all;
            access_log off;
            log_not_found off;
            return 404;
          }
        hide-headers: Server,X-Powered-By
        ssl-ciphers: EECDH+AESGCM:EDH+AESGCM
        enable-ocsp: true
        hsts-preload: true
        ssl-session-tickets: false
        client-header-timeout: 10
        client-body-timeout: 10
        large-client-header-buffers: 2 1k
        client-body-buffer-size: 1k
        proxy-body-size: 1k
        # Firewall and access control
        enable-modsecurity: true
        enable-owasp-modsecurity-crs: true
        use-geoip: false
        use-geoip2: true
        enable-real-ip: false
        whitelist-source-range: ""
        block-cidrs: ""
        block-user-agents: ""
        block-referers: ""

  # TIP: You can install more infrastructure apps on your Kubernetes with:
  # https://github.com/TaitoUnited/infra-apps-template
```

YAML attributes:

- See variables.tf for all the supported YAML attributes.
- See [kubernetes_cluster](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster) and [kubernetes_cluster_node_pool](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster_node_pool) for attribute descriptions.

Combine with the following modules to get a complete infrastructure defined by YAML:

- [Admin](https://registry.terraform.io/modules/TaitoUnited/admin/azurerm)
- [DNS](https://registry.terraform.io/modules/TaitoUnited/dns/azurerm)
- [Network](https://registry.terraform.io/modules/TaitoUnited/network/azurerm)
- [Compute](https://registry.terraform.io/modules/TaitoUnited/compute/azurerm)
- [Kubernetes](https://registry.terraform.io/modules/TaitoUnited/kubernetes/azurerm)
- [Databases](https://registry.terraform.io/modules/TaitoUnited/databases/azurerm)
- [Storage](https://registry.terraform.io/modules/TaitoUnited/storage/azurerm)
- [Monitoring](https://registry.terraform.io/modules/TaitoUnited/monitoring/azurerm)
- [Integrations](https://registry.terraform.io/modules/TaitoUnited/integrations/azurerm)
- [PostgreSQL privileges](https://registry.terraform.io/modules/TaitoUnited/privileges/postgresql)
- [MySQL privileges](https://registry.terraform.io/modules/TaitoUnited/privileges/mysql)

TIP: Similar modules are also available for AWS, Google Cloud, and DigitalOcean. All modules are used by [infrastructure templates](https://taitounited.github.io/taito-cli/templates#infrastructure-templates) of [Taito CLI](https://taitounited.github.io/taito-cli/). See also [Azure project resources](https://registry.terraform.io/modules/TaitoUnited/project-resources/azurerm), [Full Stack Helm Chart](https://github.com/TaitoUnited/taito-charts/blob/master/full-stack), and [full-stack-template](https://github.com/TaitoUnited/full-stack-template).

Contributions are welcome!
