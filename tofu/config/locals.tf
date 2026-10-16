data "cloudflare_zone" "maroonrides_app" {
  filter = {
    name = local.domain
  }
}

data "onepassword_vault" "maroonrides_deployment" {
  name = local.vault_name
}

locals {
  domain       = "maroonrides.app"
  vault_name   = "Maroon Rides Deployment"
  github_owner = "Maroon-Rides"
  admin        = "reveillerides@gmail.com"
  tailnet      = "tail9bdf1e.ts.net"
  clusters     = ["prod"]

  account_id = data.cloudflare_zone.maroonrides_app.account.id
  zone_id    = data.cloudflare_zone.maroonrides_app.id
  vault_uuid = data.onepassword_vault.maroonrides_deployment.uuid
}
