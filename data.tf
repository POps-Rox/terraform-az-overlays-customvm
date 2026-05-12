# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

# remove file if not needed
data "azurerm_client_config" "current" {}

#----------------------------------------------------------
# VNet, Subnet selection & Random Resources
#----------------------------------------------------------
data "azurerm_virtual_network" "vnet" {
  count               = var.existing_virtual_network_name != null ? 1 : 0
  name                = var.existing_virtual_network_name
  resource_group_name = var.existing_virtual_network_resource_group_name == null ? local.resource_group_name : var.existing_virtual_network_resource_group_name
}

data "azurerm_subnet" "snet" {
  count                = var.existing_subnet_name != null ? 1 : 0
  name                 = var.existing_subnet_name
  virtual_network_name = data.azurerm_virtual_network.vnet.0.name
  resource_group_name  = var.existing_virtual_network_resource_group_name == null ? local.resource_group_name : var.existing_virtual_network_resource_group_name
}

data "azurerm_network_security_group" "nsg" {
  name                = var.existing_network_security_group_name
  resource_group_name = var.existing_virtual_network_resource_group_name == null ? local.resource_group_name : var.existing_virtual_network_resource_group_name
}

data "azurerm_storage_account" "storeacc" {
  count               = var.storage_account_name != null ? 1 : 0
  name                = var.storage_account_name
  resource_group_name = local.resource_group_name
}

resource "random_password" "passwd" {
  # `var.custom_boot_image` defaults to null, so guard the attribute access
  # with `try()` to keep `tflint` happy during static analysis.
  count       = (try(var.custom_boot_image.os_type, null) == "linux" && var.disable_password_authentication == false && var.admin_password == null ? 1 : (try(var.custom_boot_image.os_type, null) == "windows" && var.admin_password == null ? 1 : 0))
  length      = var.random_password_length
  min_upper   = 4
  min_lower   = 2
  min_numeric = 4
  special     = false

  keepers = {
    admin_password = (try(var.custom_boot_image.os_type, null) == "linux" ? local.linux_vm_name : (try(var.custom_boot_image.os_type, null) == "windows" ? local.windows_vm_name : null))
  }
}
