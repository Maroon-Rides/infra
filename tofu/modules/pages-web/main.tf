locals {
  hostname       = "web.${var.domain}"
  tiles_hostname = "tiles.${var.domain}"
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

// Pages ignores Range headers, which PMTiles needs, so the web build reads the basemap from R2.
resource "cloudflare_r2_bucket" "tiles" {
  account_id = var.account_id
  name       = var.tiles_bucket_name
}

resource "cloudflare_r2_custom_domain" "tiles" {
  account_id  = var.account_id
  bucket_name = cloudflare_r2_bucket.tiles.name
  zone_id     = var.zone_id
  domain      = local.tiles_hostname
  enabled     = true
}

resource "cloudflare_r2_bucket_cors" "tiles" {
  account_id  = var.account_id
  bucket_name = cloudflare_r2_bucket.tiles.name

  rules = [
    {
      allowed = {
        methods = ["GET", "HEAD"]
        origins = ["*"]
        headers = ["Range", "If-Match"]
      }
      expose_headers  = ["ETag", "Content-Range", "Content-Length"]
      max_age_seconds = 86400
    }
  ]
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
    },
    {
      effect = "allow"
      permission_groups = [
        { id = "2efd5506f9c8494dacb1fa10a3e7d5b6" }, # Workers R2 Storage Bucket Item Write
      ]
      resources = jsonencode({
        "com.cloudflare.edge.r2.bucket.${var.account_id}_default_${cloudflare_r2_bucket.tiles.name}" = "*"
      })
    }
  ]
}

resource "github_actions_secret" "cloudflare_api_token" {
  repository      = var.repository
  secret_name     = "CLOUDFLARE_API_TOKEN"
  plaintext_value = cloudflare_account_token.pages_deploy.value
}

// R2's REST object API rejects bucket-scoped tokens, so the basemap goes up through the S3 API.
// Its credentials are derived from the token: the id is the access key and the SHA-256 of the
// value is the secret.
resource "github_actions_secret" "r2_access_key_id" {
  repository      = var.repository
  secret_name     = "R2_ACCESS_KEY_ID"
  plaintext_value = cloudflare_account_token.pages_deploy.id
}

resource "github_actions_secret" "r2_secret_access_key" {
  repository      = var.repository
  secret_name     = "R2_SECRET_ACCESS_KEY"
  plaintext_value = sha256(cloudflare_account_token.pages_deploy.value)
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

resource "github_actions_variable" "tiles_bucket" {
  repository    = var.repository
  variable_name = "MAP_TILES_BUCKET"
  value         = cloudflare_r2_bucket.tiles.name
}

resource "github_actions_variable" "tiles_url" {
  repository    = var.repository
  variable_name = "MAP_TILES_URL"
  value         = "https://${local.tiles_hostname}"
}
