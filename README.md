## terraform-aws-org
Apply this in the billing account. Double-check terraform plan (accounts are hard to delete).


## Import Existing Organization
```
terragrunt import aws_organizations_organization.this $(aws organizations describe-organization | jq -r .Organization.Id)
```


## TODO
- set alias for each account
- cross-account iam roles
- output switch-role urls (static site?)
- setup central logging/cloudtrail

