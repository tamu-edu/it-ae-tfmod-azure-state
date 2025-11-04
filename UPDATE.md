# Upgrade Guide: Version 0.2 to 0.3

This guide helps you upgrade from version 0.2 to 0.3 of the Azure Terraform State module. Several resource naming conventions and configurations have changed, requiring careful migration.

## ⚠️ Important Notice

**This upgrade requires manual intervention and state imports due to resource name changes. Plan for maintenance downtime.**

## Key Changes

### 1. Storage Container Name Change
- **Old**: Used `var.container_name` directly
- **New**: Uses `local.container_name` with environment-based naming

### 2. Storage Account Name Logic Update
- **Old**: Simple conditional logic
- **New**: Enhanced naming with environment support and 24-character limit

### 3. Data Source Logic Fix
- **Old**: `data.azurerm_resource_group.tfstate` count was incorrectly set to 1 when `create_resource_group = true`
- **New**: Properly inverted logic - count is 0 when creating RG, 1 when using existing

### 4. New Resources Added
- `azurerm_storage_account_network_rules.tfstate_acl` - Network access controls
- `data.azurerm_subscription.current` - Subscription data source

### 5. State Sanitization Changes
- **Old**: Used `terraform_data.always_run` trigger and jq-based state sanitization
- **New**: Uses `null_resource.sanitize_state` with Azure CLI key renewal
- **Variable**: `var.remove_secrets_from_state` → `var.sanitize_state_secrets`

## Pre-Upgrade Steps

1. **Backup your current Terraform state**:
   ```bash
   terraform state pull > backup-state-v0.2.json
   ```

2. **Document current resource names**:
   ```bash
   # Note your current container name
   terraform show | grep container_name
   
   # Note your current storage account name  
   terraform show | grep storage_account_name
   ```

## Upgrade Process

### Step 1: Update Module Version
Update your module reference to use version 0.3+.

### Step 2: Handle Container Name Change

If your container name will change due to the new naming logic:

```bash
# Remove the old container from state
terraform state rm module.azure_state.azurerm_storage_container.tfstate

# Import the container with new naming
terraform import module.azure_state.azurerm_storage_container.tfstate /subscriptions/{subscription-id}/resourceGroups/{rg-name}/providers/Microsoft.Storage/storageAccounts/{storage-account}/blobServices/default/containers/{NEW-container-name}
```

### Step 3: Handle Resource Group Data Source

```bash
# If you're using an existing resource group (create_resource_group = false)
# Remove the incorrectly counted data source
terraform state rm module.azure_state.data.azurerm_resource_group.tfstate

# The data source will be recreated automatically on next plan/apply
```

### Step 4: Remove Old Resources

```bash
# Remove the old terraform_data resource if it exists
terraform state rm module.azure_state.terraform_data.always_run
```

### Step 5: Plan and Apply

```bash
# Review changes
terraform plan

# Apply the changes
terraform apply
```

## Variable Updates Required

Update your variable definitions:

```hcl
# Old variable (remove)
# remove_secrets_from_state = true

# New variable (add)
sanitize_state_secrets = true

# New ACL variables (optional)
tfstate_acl_enable = false
tfstate_acl_default_action = "Allow"
tfstate_acl_ip_rule = []
tfstate_acl_bypass = ["AzureServices"]
```

## Post-Upgrade Verification

1. **Verify backend configuration**:
   ```bash
   terraform output backend_config
   ```

2. **Test state access**:
   ```bash
   terraform plan
   ```

3. **Verify container access**:
   - Check that your service principal can still access the state container
   - Verify network rules if ACL is enabled

## Rollback Plan

If issues occur:

1. **Restore state backup**:
   ```bash
   terraform state push backup-state-v0.2.json
   ```

2. **Revert module version** in your configuration

3. **Re-run terraform apply**

## Support

- Review the module's `variables.tf` for new variable options
- Check the `outputs.tf` for updated output values
- Test in a non-production environment first

---

**Need help?** Create an issue in the module repository with:
- Your current configuration
- Error messages encountered
- Steps already attempted