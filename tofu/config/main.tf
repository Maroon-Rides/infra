module "contabo" {
  source = "../modules/contabo"
}

module "dns" {
  source = "../modules/dns"

  zone_id             = local.zone_id
  hosts               = local.public_ingress_hosts
  public_ingress_ipv4 = module.contabo.public_ipv4
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
