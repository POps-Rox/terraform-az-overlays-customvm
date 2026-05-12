# v2.0.0 - 2025-05-11

## Breaking Changes
- **Provider upgrade:** Bumped `azurerm` from `~> 3.116` to `~> 4.20`
- **Terraform version:** Minimum Terraform version raised from `>= 1.9` to `>= 1.10`
- **Network interface attributes:** Renamed `enable_ip_forwarding` → `ip_forwarding_enabled`, `enable_accelerated_networking` → `accelerated_networking_enabled`

## Added
- Added `azapi` provider (`~> 2.0`) to required providers for future 4.x-native features

## Changed
- Network interface resources updated to use 4.x attribute names
- Example provider blocks: removed deprecated `skip_provider_registration`, added subscription_id comment

## Technical Notes
- **VM resource preservation:** The module continues to use the legacy `azurerm_virtual_machine` resource (deprecated but functional in 4.x) because the module architecture relies on `create_option = "Attach"` to attach pre-imported managed disks from VHDs. The 4.x `azurerm_linux_virtual_machine` and `azurerm_windows_virtual_machine` resources do not support attaching existing OS disks. Full migration to 4.x-native resources will require architectural refactoring to use captured images and is deferred to Phase 2.
- **Cross-module dependencies:** Validation currently requires patching transitive module version constraints during `terraform init`. This workaround is temporary until all POps-Rox overlay modules complete their 4.x migrations.

---

# v1.0.0 - <date>

Added
- Exposed paramters to configure Azure Spot instanaces
  of azurerm_linux_virtual_machine and azurerm_windows_virtual_machine
  Terraform ressources, so that the Spot instances can be deployed 
  with this module
