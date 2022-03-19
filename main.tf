data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "rg" {
  location = var.location
  name     = var.rg_name
}

resource "azurerm_virtual_network" "vnet" {
  address_space       = ["10.0.0.0/16"]
  location            = var.location
  name                = "gidiyan-net"
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "subnet" {
  name                 = "virtual-machine-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_key_vault" "key_vault_rg" {
  name                       = "gidiyan-key-vault"
  location                   = azurerm_resource_group.rg.location
  resource_group_name        = azurerm_resource_group.rg.name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "premium"
  soft_delete_retention_days = 7

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = [
      "backup",
      "create",
      "decrypt",
      "delete",
      "encrypt",
      "get",
      "import",
      "list",
      "purge",
      "recover",
      "restore",
      "sign",
      "unwrapKey",
      "update",
      "verify",
      "wrapKey",
    ]

    secret_permissions = [
      "backup",
      "delete",
      "get",
      "list",
      "purge",
      "recover",
      "restore",
      "set",
    ]
  }
  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = var.object_id

    key_permissions = [
      "backup",
      "create",
      "decrypt",
      "delete",
      "encrypt",
      "get",
      "import",
      "list",
      "purge",
      "recover",
      "restore",
      "sign",
      "unwrapKey",
      "update",
      "verify",
      "wrapKey",
    ]

    secret_permissions = [
      "backup",
      "delete",
      "get",
      "list",
      "purge",
      "recover",
      "restore",
      "set",
    ]
  }

}

resource "random_password" "vm_pass" {
  for_each = toset(var.vm_names)
  length   = 16
}

resource "azurerm_key_vault_secret" "secret" {
  for_each     = toset(var.vm_names)
  key_vault_id = azurerm_key_vault.key_vault_rg.id
  name         = "secret-${each.value}"
  value        = random_password.vm_pass[each.value].result
}

module "vm" {
  for_each  = toset(var.vm_names)
  source    = "git::https://gitlab.com/gidiyan/module_terraform.git//Modules/vm-module?ref=main"
  location  = azurerm_resource_group.rg.location
  rg        = azurerm_resource_group.rg.name
  pip_name  = "pip-${each.value}"
  nic_name  = "nic-${each.value}"
  subnet_id = azurerm_subnet.subnet.id
  vm_name   = each.value
  vm_pass   = random_password.vm_pass[each.value].result
}
