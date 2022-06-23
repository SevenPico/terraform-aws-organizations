# ------------------------------------------------------------------------------
# Organization
# ------------------------------------------------------------------------------
resource "aws_organizations_organization" "this" {
  feature_set                   = var.org_feature_set
  aws_service_access_principals = var.org_service_access_principals
  enabled_policy_types          = var.org_enabled_policy_types
}


# ------------------------------------------------------------------------------
# Organizational Unit
# ------------------------------------------------------------------------------
resource "aws_organizations_organizational_unit" "this" {
  for_each = var.accounts

  name      = each.key
  parent_id = aws_organizations_organization.this.roots[0].id
  tags      = module.this.tags
}


# ------------------------------------------------------------------------------
# Parent Account
# ------------------------------------------------------------------------------
resource "aws_organizations_account" "parent" {
  for_each = var.accounts

  name                       = each.value.parent
  email                      = replace(var.email_address, "@", "+${module.this.id}+${each.value.parent}@")
  close_on_deletion          = var.account_close_on_deletion && !var.enable_govcloud
  create_govcloud            = var.enable_govcloud
  iam_user_access_to_billing = var.allow_iam_user_access_to_billing ? "ALLOW" : "DENY"
  parent_id                  = aws_organizations_organizational_unit.this[each.key].id
  role_name                  = var.role_name
  tags                       = module.this.tags
}


# resource "aws_organizations_delegated_administrator" "parent" {
#   for_each = {
#     for k, v in var.accounts:
#       for p in var.org_service_access_principals:

#   }
#   account_id = aws_organizations_account.parent.id
#   service_principal = each.key
# }

#resource "aws_organizations_delegated_administrator" "org_admin" {
#  provider = aws.salient-cloud-root
#  for_each = toset([
#    "config.amazonaws.com",
#    #"cloudtrail.amazonaws.com",
#  ])

#  account_id        = local.admin_account_id
#  service_principal = each.value
#}


# ------------------------------------------------------------------------------
# Children Accounts
# ------------------------------------------------------------------------------
