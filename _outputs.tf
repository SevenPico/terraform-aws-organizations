locals {
  temp_children_map = one([
    for unit, level in var.account_hierarchy :
       {
          for c in var.account_hierarchy[unit].children :
            c.name => {
               alias   = c.alias
               profile = c.profile
            }
       }
  ])

  accounts = {
    for unit, level in var.account_hierarchy :
      unit => {
        parent = {
          id      = aws_organizations_account.parent[unit].id
          name    = aws_organizations_account.parent[unit].name
          email   = aws_organizations_account.parent[unit].email
          alias   = var.account_hierarchy[unit].parent.alias != null ? var.account_hierarchy[unit].parent.alias : "${unit}-${replace(aws_organizations_account.parent[unit].name, ".", "-")}"
          profile = var.account_hierarchy[unit].parent.profile != null ? var.account_hierarchy[unit].parent.profile : "${unit}-${replace(aws_organizations_account.parent[unit].name, ".", "-")}"
        }
        children = [
          for child in level.children: {
            id      = aws_organizations_account.child[child.name].id
            name    = aws_organizations_account.child[child.name].name
            email   = aws_organizations_account.child[child.name].email
            alias   = local.temp_children_map[child.name].alias != null ? local.temp_children_map[child.name].alias : "${unit}-${replace(aws_organizations_account.child[child.name].name, ".", "-")}"
            profile = local.temp_children_map[child.name].profile != null ? local.temp_children_map[child.name].profile : "${unit}-${replace(aws_organizations_account.child[child.name].name, ".", "-")}"
          }
        ]
      }
  }

  parent_profile_name = one([for unit, level in local.accounts : level.parent.profile])
  parent_account      = one([for unit, level in local.accounts : level.parent])
  child_accounts      = one([for unit, level in local.accounts : level.children])

  account_names_flat = merge(
    {
      for unit, level in local.accounts:
        "${level.parent.name}" => level.parent.id
    },
    [
      for unit, level in local.accounts: {
        for child in level.children:
          "${child.name}" => child.id
      }
    ]...)

  account_profiles_flat = merge(
    {
      for unit, level in local.accounts:
        "${level.parent.profile}" => level.parent.id
    },
    [
      for unit, level in local.accounts: {
        for child in level.children:
          "${child.profile}" => child.id
      }
    ]...)

  account_aliases_flat = merge(
    {
     for unit, level in local.accounts:
      "${level.parent.alias}" => level.parent.id
    },
    [
     for unit, level in local.accounts: {
      for child in level.children:
       "${child.alias}" => child.id
    }
    ]...)
}


output "accounts" {
  value = local.accounts
}

output "parent_account" {
  value = local.parent_account
}

output "child_accounts" {
  value = local.child_accounts
}

output "account_names_flat" {
  value = local.account_names_flat
}

output "account_profiles_flat" {
  value = local.account_profiles_flat
}

output "account_aliases_flat" {
  value = local.account_aliases_flat
}

output "swtichrole_urls" {
  value = [
    for name, id in local.account_names_flat:
      "https://signin.aws.amazon.com/switchrole?account=${id}&roleName=${var.access_role_name}&displayName=${urlencode(name)}"
  ]
}

output "aws_config_profiles" {
  value = join("\n", [
    for profile, id in local.account_profiles_flat:
<<FMT
[profile ${profile}]
source_profile = ${local.parent_profile_name}
role_arn       = arn:aws::iam:${id}:role/${var.access_role_name}
color          = ${substr(sha1(id), 0, 6)}
FMT
  ])
}

output "access_role_name" {
  value = var.access_role_name
}

output "context" {
  value = module.meta.context
}
