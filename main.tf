module "main" {
  source                   = "./module/"
  tfcloud_org              = var.tfcloud_org
  catch_all_forward_emails = var.catch_all_forward_emails
  domain                   = var.domain
  webfinger_redirect_url   = var.webfinger_redirect_url
}
