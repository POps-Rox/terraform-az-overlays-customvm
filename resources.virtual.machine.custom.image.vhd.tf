
resource "azurerm_managed_disk" "custom_boot_image" {
  count                = var.instances_count
  name                 = local.vm_os_disk_name
  location             = local.location
  resource_group_name  = local.resource_group_name
  storage_account_type = try(var.custom_boot_image.storage_acct_type, null)
  create_option        = "Import"
  source_uri           = try(var.custom_boot_image.storage_uri, null)
  storage_account_id   = try(var.custom_boot_image.storage_acct_id, null)
  os_type              = try(var.custom_boot_image.os_type, null)
  disk_size_gb         = try(var.custom_boot_image.disk_size_gb, null)
  zone                 = try(var.custom_boot_image.availability_zone, null)
  tags                 = merge({ "ResourceName" = local.vm_os_disk_name }, var.add_tags, var.os_disk_add_tags, )

  lifecycle {
    ignore_changes = [
      tags,
    ]
  }
}
