module "contabo" {
  source = "../modules/contabo"
}

module "api_tokens" {
  source = "../modules/api-tokens"

  account_id = local.account_id
  zone_id    = local.zone_id
  vault_uuid = local.vault_uuid
}

module "restic" {
  source = "../modules/restic"

  account_id  = local.account_id
  vault_uuid  = local.vault_uuid
  bucket_name = "maroonrides-volsync"
}

module "tailscale" {
  source = "../modules/tailscale"

  clusters   = toset(local.clusters)
  admin      = local.admin
  vault_uuid = local.vault_uuid
}

module "flux_webhooks" {
  source = "../modules/flux-webhooks"

  clusters   = toset(local.clusters)
  repository = "infra"
  domain     = local.domain
  vault_uuid = local.vault_uuid
}

module "pages_web" {
  source = "../modules/pages-web"

  account_id        = local.account_id
  zone_id           = local.zone_id
  domain            = local.domain
  project_name      = "maroonrides-web"
  tiles_bucket_name = "maroonrides-map-tiles"
  repository        = "MaroonRides"
}

module "pages_site" {
  source = "../modules/pages-site"

  account_id        = local.account_id
  zone_id           = local.zone_id
  domain            = local.domain
  project_name      = "maroonrides-site"
  production_branch = "master"
  repository        = "maroon-rides.github.io"
}
