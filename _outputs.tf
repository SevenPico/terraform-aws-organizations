output "accounts" {
  value = {
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
}

output "access_role_name" {
  value = var.access_role_name
}
