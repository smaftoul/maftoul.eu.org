terraform {
  cloud {
    organization = var.tfcloud_org
    hostname     = "app.terraform.io"
    workspaces {
      name = "cloudflare"
    }
  }
}
