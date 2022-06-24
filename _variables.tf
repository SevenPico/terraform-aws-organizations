variable "email_base_address" {
  type = string
}

variable "accounts" {
  type = map(object({
    parent   = string
    children = list(string)
  }))
}

variable "org_enabled_policy_types" {
  type    = list(string)
  default = []
}

variable "org_service_access_principals" {
  type = list(string)
  default = [
    "account.amazonaws.com",
    "cloudtrail.amazonaws.com",
    "config.amazonaws.com",
  ]
  description = <<DOC
  Refer to: https://docs.aws.amazon.com/organizations/latest/userguide/orgs_integrate_services_list.html
  DOC
}

variable "delegated_admin_principals" {
  type = list(string)
  default = [
    "account.amazonaws.com",
    "config.amazonaws.com",
  ]
}

variable "org_feature_set" {
  type    = string
  default = "ALL"
}

variable "account_close_on_deletion" {
  type    = bool
  default = true
}

variable "enable_govcloud" {
  type    = bool
  default = false
}

variable "allow_iam_user_access_to_billing" {
  type    = bool
  default = true
}

variable "access_role_name" {
  type    = string
  default = "OrganizationAccountAccessRole"
}

variable "profile" {
  type = string
}
