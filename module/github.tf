resource "github_repository" "self" {
  name                 = var.domain
  has_downloads        = true
  has_issues           = true
  has_projects         = true
  visibility           = "public"
  vulnerability_alerts = true
}

resource "github_repository" "blog" {
  name                 = "blog"
  has_downloads        = true
  has_issues           = true
  has_projects         = true
  visibility           = "public"
  vulnerability_alerts = true
  template {
    include_all_branches = false
    owner                = "11ty"
    repository           = "eleventy-base-blog"
  }
}

