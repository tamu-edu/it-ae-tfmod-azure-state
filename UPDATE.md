# Migration Guide

## Migrating from Module-Managed Resource Groups

> [!WARNING]
> **Breaking change:** If you were previously using `v0.2` of this module with the `create_resource_group` option (default `true`), you'll need to migrate your existing state to account for the resource group no longer being managed by this module, or the resource group, tfstate, and _all resources_ within **will be destroyed**.
>
> ### Step 1: Update Your Module Configuration

Replace your existing module configuration:

```hcl
# OLD configuration
module "state_backend" {
  source = "github.com/tamu-edu/it-ae-tfmod-azure-state?ref=v0.2"

  create_resource_group = true     # <-- default is true
  resource_group_name   = "rg-terraform-state"
  location             = "southcentralus"
  storage_account_name = "tfstateaccount12345"
  # ... other variables
}
```

With the new configuration:

```hcl
# NEW configuration - create resource group separately if one is needed to be created
resource "azurerm_resource_group" "tfstate" {
  name     = "rg-terraform-state-dev"
  location = "southcentralus"
}

module "state_backend" {
  source = "github.com/tamu-edu/it-ae-tfmod-azure-state?ref=v0.3"

  resource_group_name  = azurerm_resource_group.tfstate.name
  location            = azurerm_resource_group.tfstate.location
  storage_account_name = "tfstateaccount12345"
  # ... other variables
}
```

### Step 2: Add the Moved Block

First determine whether your resource group has a trailing `[0]` or not:

```
terraform state list | grep resource_group
```

Add this `moved` block to your Terraform configuration to migrate the resource group from the module to your root configuration:

```hcl
moved {
  from = module.state_backend.azurerm_resource_group.tfstate[0] # or without the [0]
  to   = azurerm_resource_group.tfstate
}
```

### Step 3: Run Terraform Plan

Execute `terraform plan` to verify that Terraform recognizes the moved resource:

```bash
terraform plan
```

You should see output indicating that the resource group will be moved, not destroyed and recreated. If you see something like the following, then adjust the `[0]` in your move block and rerun `terraform plan`:

```
  # azurerm_resource_group.tfstate[0] will be destroyed
  # (because resource does not use count)
  # (moved from module.state_backend.azurerm_resource_group.tfstate[0])
  - resource "azurerm_resource_group" "tfstate" {
    ...
```

### Step 4: Apply the Changes

Once you've confirmed the plan looks correct, apply the changes:

```bash
terraform apply
```

### Step 5: Remove the Moved Block (Optional)

After successfully applying the changes, you can remove the `moved` block from your configuration as it's no longer needed.