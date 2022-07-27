locals {
  accounts = {
    for project, level in var.account_hierarchy :
      project => {
        parent = {
          alias   = var.account_hierarchy[project].parent.alias != null ? var.account_hierarchy[project].parent.alias : "${project}-${replace(aws_organizations_account.parent[project].name, ".", "-")}"
          id      = aws_organizations_account.parent[project].id
          email   = aws_organizations_account.parent[project].email
          name    = aws_organizations_account.parent[project].name
          profile = var.account_hierarchy[project].parent.profile != null ? var.account_hierarchy[project].parent.profile : "${project}-${replace(aws_organizations_account.parent[project].name, ".", "-")}"
        }
        children = [
          for child in level.children: {
            alias   = child.alias
            email   = aws_organizations_account.child["${project}-${child.alias}"].email
            id      = aws_organizations_account.child["${project}-${child.alias}"].id
            name    = aws_organizations_account.child["${project}-${child.alias}"].name
            profile = child.profile
          }
        ]
      }
  }

  parent_profile_name = one([for project, level in local.accounts : level.parent.profile])
  parent_account      = one([for project, level in local.accounts : level.parent])

  account_names_flat = merge(
    {
      for project, level in local.accounts:
        "${level.parent.name}" => level.parent.id
    },
    [
      for project, level in local.accounts: {
        for child in level.children:
          "${child.name}" => child.id
      }
    ]...)

#  account_profiles_flat = merge(
#    {
#      for project, level in local.accounts:
#        "${level.parent.profile}" => level.parent.id
#    },
#    [
#      for project, level in local.accounts: {
#        for child in level.children:
#          "${child.profile}" => child.id
#      }
#    ]...)

  account_aliases_flat = merge(
    {
     for project, level in local.accounts:
      "${level.parent.alias}" => level.parent.id
    },
    [
     for project, level in local.accounts: {
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

output "account_names_flat" {
  value = local.account_names_flat
}

#output "account_profiles_flat" {
#  value = local.account_profiles_flat
#}

output "account_aliases_flat" {
  value = local.account_aliases_flat
}

output "swtichrole_urls" {
  value = [
    for name, id in local.account_names_flat:
      "https://signin.aws.amazon.com/switchrole?account=${id}&roleName=${var.access_role_name}&displayName=${urlencode(name)}"
  ]
}

#output "aws_config_profiles" {
#  value = join("\n", [
#    for profile, id in local.account_profiles_flat:
#<<FMT
#[profile ${profile}]
#source_profile = ${local.parent_profile_name}
#role_arn       = arn:aws::iam:${id}:role/${var.access_role_name}
#color          = ${substr(sha1(id), 0, 6)}
#FMT
#  ])
#}

output "access_role_name" {
  value = var.access_role_name
}
