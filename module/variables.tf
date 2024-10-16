variable "domain" {
  description = "The domain to manage"
  type        = string
}

variable "catch_all_forward_emails" {
  description = "Email addresses to forward all emails to"
  type        = list(string)
}

variable "tfcloud_org" {
  description = "The Terraform Cloud organization to use"
  type        = string
}
