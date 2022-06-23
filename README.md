## terraform-aws-org
Apply this in the billing account. Double-check terraform plan (accounts are hard to delete).


## Import Existing
```
# Existing Organization
terraform import 'aws_organizations_organization.this' $(aws organizations describe-organization | jq -r .Organization.Id)

# Existing Organizational Units
terraform import 'aws_organizations_organizational_unit.this["example"]' ou-abc-123

# Existing accounts
terraform import 'aws_organizations_account.parent["example"]' 123456789
terraform import 'aws_organizations_account.child["example-dev"]' 987654321
```
