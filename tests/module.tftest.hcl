mock_provider "azurerm" {}
mock_provider "azapi" {}
mock_provider "popsrox" {}
mock_provider "random" {}
mock_provider "tls" {}

variables {
  location                     = "eastus2"
  deploy_environment           = "test"
  workload_name                = "customvm"
  org_name                     = "contoso"
  existing_resource_group_name = "rg-existing"

  existing_virtual_network_resource_group_name = "rg-network"
  existing_virtual_network_name                = "vnet-existing"
  existing_subnet_name                         = "snet-existing"
  existing_network_security_group_name         = "nsg-existing"

  admin_username = "azureadmin"
  custom_boot_image = {
    os_type           = "Linux"
    storage_uri       = "https://storage.example/vhds/linux.vhd"
    storage_acct_id   = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-storage/providers/Microsoft.Storage/storageAccounts/stlinux"
    storage_acct_type = "StandardSSD_LRS"
    disk_size_gb      = 64
  }
}

override_module {
  target = module.mod_azregions
  outputs = {
    location_cli   = "eastus2"
    location_short = "eus2"
  }
}

override_data {
  target = data.azurerm_client_config.current
  values = {
    subscription_id = "00000000-0000-0000-0000-000000000000"
    tenant_id       = "11111111-1111-1111-1111-111111111111"
    client_id       = "22222222-2222-2222-2222-222222222222"
    object_id       = "33333333-3333-3333-3333-333333333333"
  }
}

override_data {
  target = data.azurerm_resource_group.rgrp[0]
  values = {
    name     = "rg-existing"
    location = "eastus2"
  }
}

override_data {
  target = data.azurerm_virtual_network.vnet[0]
  values = {
    name                = "vnet-existing"
    resource_group_name = "rg-network"
    id                  = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-network/providers/Microsoft.Network/virtualNetworks/vnet-existing"
  }
}

override_data {
  target = data.azurerm_subnet.snet[0]
  values = {
    name             = "snet-existing"
    address_prefixes = ["10.10.1.0/24"]
    id               = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-network/providers/Microsoft.Network/virtualNetworks/vnet-existing/subnets/snet-existing"
  }
}

override_data {
  target = data.azurerm_network_security_group.nsg
  values = {
    name                = "nsg-existing"
    resource_group_name = "rg-network"
    id                  = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-network/providers/Microsoft.Network/networkSecurityGroups/nsg-existing"
  }
}

override_data {
  target = data.azurerm_storage_account.storeacc[0]
  values = {
    name                  = "stdiag"
    id                    = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-existing/providers/Microsoft.Storage/storageAccounts/stdiag"
    primary_blob_endpoint = "https://stdiag.blob.core.windows.net/"
  }
}

override_data {
  target = data.popsrox_resource_name.vm_linux
  values = {
    result = "generated-linux-vm"
  }
}

override_data {
  target = data.popsrox_resource_name.vm_windows
  values = {
    result = "generated-windows-vm"
  }
}

override_data {
  target = data.popsrox_resource_name.computer_windows
  values = {
    result = "generated-computer"
  }
}

override_data {
  target = data.popsrox_resource_name.pub_ip
  values = {
    result = "generated-pip"
  }
}

override_data {
  target = data.popsrox_resource_name.nic
  values = {
    result = "generated-nic"
  }
}

override_data {
  target = data.popsrox_resource_name.secnic
  values = {
    result = "generated-secondary-nic"
  }
}

override_data {
  target = data.popsrox_resource_name.nsg
  values = {
    result = "generated-nsg"
  }
}

override_data {
  target = data.popsrox_resource_name.disk
  values = {
    result = "generated-osdisk"
  }
}

override_data {
  target = data.popsrox_resource_name.avset
  values = {
    result = "generated-avset"
  }
}

override_data {
  target = data.popsrox_resource_name.ppg
  values = {
    result = "generated-ppg"
  }
}

run "linux_existing_vhd_enabled_features" {
  command = plan

  variables {
    custom_linux_vm_name               = "custom-linux"
    custom_nic_name                    = "custom-nic"
    custom_public_ip_name              = "custom-pip"
    custom_ipconfig_name               = "custom-ipconfig"
    os_disk_custom_name                = "custom-osdisk"
    enable_public_ip_address           = true
    enable_vm_availability_set         = true
    enable_proximity_placement_group   = true
    enable_boot_diagnostics            = true
    storage_account_name               = "stdiag"
    private_ip_address_allocation_type = "Static"
    private_ip_address                 = ["10.10.1.10"]
    disable_password_authentication    = true
    admin_ssh_key_data                 = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDFakeKeyForTerraformTestOnly"
    nsg_inbound_rules = [
      {
        name                   = "ssh"
        destination_port_range = "22"
        source_address_prefix  = "*"
      }
    ]
    add_tags = {
      env   = "test"
      owner = "platform"
    }
    nic_add_tags = {
      component = "nic"
    }
    public_ip_add_tags = {
      component = "pip"
    }
    os_disk_add_tags = {
      component = "disk"
    }
  }

  assert {
    condition     = azurerm_virtual_machine.custom_vm[0].name == "custom-linux"
    error_message = "custom_linux_vm_name must take precedence over generated VM names."
  }

  assert {
    condition     = azurerm_network_interface.nic[0].name == "custom-nic"
    error_message = "custom_nic_name must take precedence over generated NIC names."
  }

  assert {
    condition     = azurerm_network_interface.nic[0].ip_configuration[0].name == "ipconfig-customipconfig1"
    error_message = "custom_ipconfig_name must take precedence when naming the primary NIC IP configuration."
  }

  assert {
    condition     = azurerm_managed_disk.custom_boot_image[0].name == "custom-osdisk"
    error_message = "os_disk_custom_name must take precedence over generated OS disk names."
  }

  assert {
    condition     = length(azurerm_public_ip.pip) == 1 && azurerm_public_ip.pip[0].name == "custom-pip-01"
    error_message = "enable_public_ip_address=true must create one public IP using the custom public IP prefix."
  }

  assert {
    condition     = length(azurerm_availability_set.aset) == 1 && length(azurerm_proximity_placement_group.appgrp) == 1
    error_message = "Availability set and proximity placement group must be created when enabled."
  }

  assert {
    condition     = azurerm_virtual_machine.custom_vm[0].location == "eastus2" && azurerm_network_interface.nic[0].location == "eastus2"
    error_message = "VM and NIC resources must use the resolved resource-group location."
  }

  assert {
    condition     = azurerm_public_ip.pip[0].tags["env"] == "test" && azurerm_public_ip.pip[0].tags["owner"] == "platform" && azurerm_public_ip.pip[0].tags["component"] == "pip" && azurerm_public_ip.pip[0].tags["ResourceName"] == "custom-pip-01"
    error_message = "Public IP tags must merge ResourceName, add_tags, and public_ip_add_tags."
  }

  assert {
    condition     = azurerm_network_interface.nic[0].tags["component"] == "nic" && azurerm_managed_disk.custom_boot_image[0].tags["component"] == "disk"
    error_message = "Resource-specific tag maps must be merged onto NICs and OS disks."
  }

  assert {
    condition     = azurerm_managed_disk.custom_boot_image[0].create_option == "Import" && azurerm_virtual_machine.custom_vm[0].storage_os_disk[0].create_option == "Attach"
    error_message = "The existing-VHD path must import a managed disk and attach it as the VM OS disk."
  }

  assert {
    condition     = azurerm_virtual_machine.custom_vm[0].storage_os_disk[0].os_type == "Linux" && length(azurerm_virtual_machine.custom_vm[0].os_profile_linux_config) == 1
    error_message = "Linux custom_boot_image.os_type must attach the OS disk and emit Linux OS profile config."
  }

  assert {
    condition     = azurerm_virtual_machine.custom_vm[0].boot_diagnostics[0].enabled == true && azurerm_virtual_machine.custom_vm[0].boot_diagnostics[0].storage_uri == "https://stdiag.blob.core.windows.net/"
    error_message = "enable_boot_diagnostics=true must configure boot diagnostics with the selected storage account."
  }

  assert {
    condition     = output.linux_vm_name != null && output.windows_vm_name == null
    error_message = "Linux OS type, including mixed-case input, must drive Linux outputs only."
  }
}

run "windows_empty_names_disabled_features" {
  command = plan

  variables {
    custom_linux_vm_name             = ""
    custom_windows_vm_name           = ""
    custom_nic_name                  = ""
    custom_public_ip_name            = ""
    custom_ipconfig_name             = ""
    os_disk_custom_name              = ""
    enable_public_ip_address         = false
    enable_vm_availability_set       = false
    enable_proximity_placement_group = false
    enable_boot_diagnostics          = false
    disable_password_authentication  = false
    admin_password                   = "P@ssw0rd1234!"
    custom_boot_image = {
      os_type           = "windows"
      storage_uri       = "https://storage.example/vhds/windows.vhd"
      storage_acct_id   = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-storage/providers/Microsoft.Storage/storageAccounts/stwindows"
      storage_acct_type = "StandardSSD_LRS"
      disk_size_gb      = 128
    }
    add_tags = {
      owner = "platform"
    }
    nic_add_tags = {
      component = "nic"
    }
  }

  assert {
    condition     = azurerm_virtual_machine.custom_vm[0].name == "generated-windows-vm"
    error_message = "Empty custom Windows VM names must fall through to generated Windows names instead of producing an empty VM name."
  }

  assert {
    condition     = azurerm_network_interface.nic[0].name == "generated-nic"
    error_message = "Empty custom_nic_name must fall through to the generated NIC name."
  }

  assert {
    condition     = azurerm_network_interface.nic[0].ip_configuration[0].name == "ipconfig-vmnicipconfig1"
    error_message = "Empty custom_ipconfig_name must fall through to the default IP configuration name."
  }

  assert {
    condition     = azurerm_managed_disk.custom_boot_image[0].name == "generated-osdisk"
    error_message = "Empty os_disk_custom_name must fall through to the generated OS disk name."
  }

  assert {
    condition     = length(azurerm_public_ip.pip) == 0 && length(azurerm_availability_set.aset) == 0 && length(azurerm_proximity_placement_group.appgrp) == 0
    error_message = "Disabled public IP, availability set, and proximity placement group flags must create zero resources."
  }

  assert {
    condition     = length(azurerm_virtual_machine.custom_vm[0].boot_diagnostics) == 0
    error_message = "enable_boot_diagnostics=false must omit boot diagnostics."
  }

  assert {
    condition     = length(azurerm_virtual_machine.custom_vm[0].os_profile_linux_config) == 0 && output.windows_vm_name != null && output.linux_vm_name == null
    error_message = "Windows OS type must omit Linux config and drive Windows outputs only."
  }

  assert {
    condition     = azurerm_network_interface.nic[0].tags["owner"] == "platform" && azurerm_network_interface.nic[0].tags["component"] == "nic" && azurerm_network_interface.nic[0].tags["ResourceName"] == "generated-nic"
    error_message = "NIC tags must merge ResourceName, add_tags, and nic_add_tags with generated-name fallthrough."
  }
}
