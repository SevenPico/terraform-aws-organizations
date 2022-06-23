

module "org" {
  source = "../.."

  namespace = "example"

  email_address                    = "brad@7pi.co"
  enable_govcloud                  = false
  allow_iam_user_access_to_billing = true
  account_close_on_deletion        = true
  role_name                        = "example-org-role"
  org_enabled_policy_types         = []
  org_service_access_principals    = ["cloudtrail.amazonaws.com", "config.amazonaws.com"]
  org_feature_set                  = "ALL"


  accounts = {
    sfc = {
      parent   = "admin"
      children = ["dev", "qa"]
    }
  }

}


