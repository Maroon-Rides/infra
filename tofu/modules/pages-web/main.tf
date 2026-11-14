locals {
  hostname = "web.${var.domain}"
}

// Deployments are direct uploads from GitHub Actions, so the project has no git source.
resource "cloudflare_pages_project" "web" {
  account_id        = var.account_id
  name              = var.project_name
  production_branch = "main"
}

resource "cloudflare_pages_domain" "web" {
  account_id   = var.account_id
  project_name = cloudflare_pages_project.web.name
  name         = local.hostname
}

resource "cloudflare_dns_record" "web" {
  zone_id = var.zone_id
  name    = local.hostname
  type    = "CNAME"
  content = cloudflare_pages_project.web.subdomain
  proxied = true
  ttl     = 1
}

resource "cloudflare_account_token" "pages_deploy" {
  account_id = var.account_id
  name       = "maroonrides pages deploy"

  policies = [
    {
      effect = "allow"
      permission_groups = [
        { id = "8d28297797f24fb8a0c332fe0866ec89" }, # Pages Write
      ]
      resources = jsonencode({
        "com.cloudflare.api.account.${var.account_id}" = "*"
      })
    }
  ]
}

resource "github_actions_secret" "cloudflare_api_token" {
  repository      = var.repository
  secret_name     = "CLOUDFLARE_API_TOKEN"
  plaintext_value = cloudflare_account_token.pages_deploy.value
}

resource "github_actions_variable" "cloudflare_account_id" {
  repository    = var.repository
  variable_name = "CLOUDFLARE_ACCOUNT_ID"
  value         = var.account_id
}

resource "github_actions_variable" "pages_project" {
  repository    = var.repository
  variable_name = "CLOUDFLARE_PAGES_PROJECT"
  value         = cloudflare_pages_project.web.name
}
