locals {
  accounts = {
    for k, v in var.accounts :
      k => {
        parent = {
          name = v.parent
          id = aws_organizations_account.parent[k].id
        }
        children = [
          for c in v.children: {
            name = c
            id = aws_organizations_account.child["${k}-${c}"].id
          }
        ]
      }
  }

  accounts_flat = merge(
    {
      for k, v in local.accounts:
        "${k}-${v.parent.name}" => v.parent.id
    },
    [
      for k, v in local.accounts: {
        for c in v.children:
          "${k}-${c.name}" => c.id
      }
    ]...)
}


output "accounts" {
  value = local.accounts
}

output "accounts_flat" {
  value = local.accounts
}

output "swtichrole_urls" {
  value = [
    for name, id in local.accounts_flat:
      "https://signin.aws.amazon.com/switchrole?account=${id}&roleName=${var.access_role_name}&displayName=${name}"
  ]
}

output "access_role_name" {
  value = var.access_role_name
}
