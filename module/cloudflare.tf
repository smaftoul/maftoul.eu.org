data "cloudflare_accounts" "current" {}

locals {
  cloudflare_account_id = data.cloudflare_accounts.current.accounts[0].id
}


resource "cloudflare_zone" "zone" {
  account_id = local.cloudflare_account_id
  paused     = false
  plan       = "free"
  type       = "full"
  zone       = var.domain
}

resource "cloudflare_zone_dnssec" "dnssec" {
  zone_id = cloudflare_zone.zone.id
}

resource "cloudflare_email_routing_settings" "my_zone" {
  zone_id = cloudflare_zone.zone.id
  enabled = "true"
}

resource "cloudflare_email_routing_catch_all" "catch_all" {
  zone_id = cloudflare_zone.zone.id
  name    = "catch all"
  enabled = true

  matcher {
    type = "all"
  }

  action {
    type  = "forward"
    value = var.catch_all_forward_emails
  }
}

resource "cloudflare_pages_project" "project" {
  account_id        = local.cloudflare_account_id
  name              = "main"
  production_branch = "main"
  source {
    type = "github"
    config {
      owner                         = split("/", github_repository.blog.full_name)[0]
      repo_name                     = github_repository.blog.name
      production_branch             = "main"
      pr_comments_enabled           = true
      deployments_enabled           = true
      production_deployment_enabled = true
      preview_deployment_setting    = "custom"
      preview_branch_includes       = ["dev", "preview"]
      preview_branch_excludes       = ["main", "prod"]
    }
  }
  build_config {
    build_command   = "npx @11ty/eleventy"
    destination_dir = "_site"
    root_dir        = "/"
  }

  deployment_configs {
    production {}
  }
}

resource "cloudflare_pages_domain" "domain" {
  account_id   = local.cloudflare_account_id
  project_name = cloudflare_pages_project.project.name
  domain       = var.domain
}

# DNS record for the custom domain
resource "cloudflare_record" "domain" {
  zone_id = cloudflare_zone.zone.id
  name    = "@"
  content = cloudflare_pages_project.project.domains[0]
  type    = "CNAME"
  proxied = "true"
  ttl     = 1
  comment = "Page: ${cloudflare_pages_project.project.name}"
}

resource "cloudflare_page_rule" "webfinger_redirect" {
  zone_id = cloudflare_zone.zone.id
  target  = "${var.domain}/.well-known/webfinger?*"

  actions {
    forwarding_url {
      url         = var.webfinger_redirect_url
      status_code = 302
    }
  }
}
