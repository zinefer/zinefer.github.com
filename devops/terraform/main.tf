locals {
  clean_lets_encrypt_azure = replace(var.lets_encrypt_azure, "-", "")
}

provider "azurerm" {
  version = "~> 2.4.0" # https://github.com/terraform-providers/terraform-provider-azurerm/issues/1109
  features {}
}

data "azurerm_client_config" "current" {}

# May need to run 
# New-AzureRmADServicePrincipal -ApplicationId "205478c0-bd83-4e1b-a9d6-db63a3e1e1c8"
# One time, tenant wide for this data call to work
data "azuread_service_principal" "cdn" {
  display_name = "Microsoft.Azure.Cdn"
}

data "azuread_service_principal" "certs" {
  display_name = var.lets_encrypt_azure
}

data "azurerm_storage_account" "certs_config" {
  name                = local.clean_lets_encrypt_azure
  resource_group_name = var.lets_encrypt_azure
}

resource "azurerm_resource_group" "site" {
  name     = var.site
  location = var.location
}

resource "azurerm_storage_account" "site" {
  name                      = var.site
  resource_group_name       = azurerm_resource_group.site.name
  location                  = var.location
  account_replication_type  = "LRS"
  account_tier              = "Standard"
  account_kind              = "StorageV2"
  enable_https_traffic_only = false #true

  static_website {
    index_document     = "index.html"
    error_404_document = "error.html"
  }
}

resource "azurerm_cdn_profile" "site" {
  name                = var.site
  location            = azurerm_resource_group.site.location
  resource_group_name = azurerm_resource_group.site.name
  sku                 = "Premium_Verizon"
}

resource "azurerm_cdn_endpoint" "site" {
  name                = var.site
  profile_name        = azurerm_cdn_profile.site.name
  location            = azurerm_resource_group.site.location
  resource_group_name = azurerm_resource_group.site.name

  querystring_caching_behaviour = "NotSet"

  origin_host_header = azurerm_storage_account.site.primary_web_host
  origin {
    name       = replace(azurerm_storage_account.site.primary_web_host, ".", "-")
    host_name  = azurerm_storage_account.site.primary_web_host
    http_port  = 80
    https_port = 443
  }
}

resource "azurerm_key_vault" "certs" {
  name                = var.site
  location            = azurerm_resource_group.site.location
  resource_group_name = azurerm_resource_group.site.name
  tenant_id           = data.azurerm_client_config.current.tenant_id

  sku_name = "standard"

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = [
      "list"
    ]

    secret_permissions = [
      "list",
      "get"
    ]

    certificate_permissions = [
      "list"
    ]
  }

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azuread_service_principal.certs.object_id

    secret_permissions = [
      "get", "list"
    ]

    certificate_permissions = [
      "get", "list", "import", "update"
    ]
  }

  /*network_acls {
    bypass         = "AzureServices"
    default_action = "Deny"
    ip_rules       = [local.my_ip]
  }*/
}

resource "azurerm_key_vault_access_policy" "certs" {
  key_vault_id = azurerm_key_vault.certs.id

  tenant_id = data.azurerm_client_config.current.tenant_id
  object_id = data.azuread_service_principal.cdn.object_id

  secret_permissions = [
    "get", "list"
  ]

  certificate_permissions = [
    "get", "list"
  ] 
}

resource "azurerm_storage_blob" "certs" {
  name                   = "config/jameskiefer.json"
  storage_account_name   = data.azurerm_storage_account.certs_config.name
  storage_container_name = "letsencrypt"
  type                   = "Block"
  source_content         = <<EOF
    {
        "acme": {
            "email": "zinefer@gmail.com",
            "renewXDaysBeforeExpiry": 30,
            "staging": false
        },
        "certificates": [
            {
                "hostNames": [
                    "jameskiefer.com",
                    "www.jameskiefer.com"
                ],
                "targetResource": {
                    "type": "cdn",
                    "name": "jameskiefer"
                }
            }
        ]
    }
  EOF
}

# TODO: Add custom domains when the Terraform Azure provider supports them

resource "azurerm_role_assignment" "certsCdnProfileReader" {
  scope                = azurerm_cdn_profile.site.id
  role_definition_name = "CDN Profile Reader"
  principal_id         = data.azuread_service_principal.certs.object_id
}

resource "azurerm_role_assignment" "certsCdnEndpointContributor" {
  scope                = azurerm_cdn_endpoint.site.id
  role_definition_name = "CDN Endpoint Contributor"
  principal_id         = data.azuread_service_principal.certs.object_id
}

resource "azurerm_role_assignment" "certsKeyvaultContributor" {
  scope                = azurerm_key_vault.certs.id
  role_definition_name = "Key Vault Contributor"
  principal_id         = data.azuread_service_principal.certs.object_id
}

resource "azurerm_role_assignment" "certsStorageContributor" {
  scope                = azurerm_storage_account.site.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = data.azuread_service_principal.certs.object_id
}
