# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

terraform {
  required_version = ">= 1.10"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.20"
    }
    azapi = {
      source  = "azure/azapi"
      version = "~> 2.0"
    }
    popsrox = {
      source  = "POps-Rox/azutils"
      version = "~> 1.0"
    }
  }
}

# Azurerm provider configuration
provider "azurerm" {
  environment = "usgovernment"
  # subscription_id is provided by the consumer via ARM_SUBSCRIPTION_ID env var
  features {}
}

provider "azurerm" {
  alias           = "custom_image"
  subscription_id = coalesce(var.custom_boot_image.storage_acct_subscription_id, data.azurerm_client_config.current.subscription_id)
  features {}
}