locals {
  admin_service_principal_map = {
    for t in setproduct(keys(var.accounts), var.delegated_admin_principals) :
    "${t[0]}-${t[1]}" => {
      account_id        = try(aws_organizations_account.parent[t[0]].id, "")
      service_principal = try(t[1], "")
    }
  }

  org_unit_child_map = merge([
    for k, v in var.accounts : {
      for c in v.children :
      "${k}-${c}" => {
        org_unit = k
        child = c
      }
    }
  ]...)
}


# ------------------------------------------------------------------------------
# Organization
# ------------------------------------------------------------------------------
resource "aws_organizations_organization" "this" {
  count = module.this.enabled ? 1 : 0

  feature_set                   = var.org_feature_set
  aws_service_access_principals = var.org_service_access_principals
  enabled_policy_types          = var.org_enabled_policy_types
}


# ------------------------------------------------------------------------------
# Organizational Unit
# ------------------------------------------------------------------------------
resource "aws_organizations_organizational_unit" "this" {
  for_each = module.this.enabled ? var.accounts : {}

  name      = each.key
  parent_id = one(aws_organizations_organization.this[*].roots[0].id)
  tags      = module.this.tags
}


# ------------------------------------------------------------------------------
# Parent Account
# ------------------------------------------------------------------------------
resource "aws_organizations_account" "parent" {
  for_each = module.this.enabled ? var.accounts : {}

  name                       = each.value.parent
  email                      = replace(var.email_base_address, "@", "+${each.key}+${each.value.parent}@")
  close_on_deletion          = var.account_close_on_deletion && !var.enable_govcloud
  create_govcloud            = var.enable_govcloud
  iam_user_access_to_billing = var.allow_iam_user_access_to_billing ? "ALLOW" : "DENY"
  parent_id                  = aws_organizations_organizational_unit.this[each.key].id
  role_name                  = var.access_role_name
  tags                       = module.this.tags

  lifecycle {
    ignore_changes = [
      email,
      iam_user_access_to_billing,
      name,
      role_name
    ]
  }
}

resource "aws_organizations_delegated_administrator" "parent" {
  for_each = module.this.enabled ? local.admin_service_principal_map : {}

  account_id        = each.value.account_id
  service_principal = each.value.service_principal
}


# ------------------------------------------------------------------------------
# Children Accounts
# ------------------------------------------------------------------------------
resource "aws_organizations_account" "child" {
  for_each = module.this.enabled ? local.org_unit_child_map : {}

  name                       = each.value.child
  email                      = replace(var.email_base_address, "@", "+${each.value.org_unit}+${each.value.child}@")
  close_on_deletion          = var.account_close_on_deletion && !var.enable_govcloud
  create_govcloud            = var.enable_govcloud
  iam_user_access_to_billing = var.allow_iam_user_access_to_billing ? "ALLOW" : "DENY"
  parent_id                  = aws_organizations_organizational_unit.this[each.value.org_unit].id
  role_name                  = var.access_role_name
  tags                       = module.this.tags
}
