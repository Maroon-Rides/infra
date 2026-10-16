locals {
  public_ingress_hosts = toset([
    "api",
    "auth",
    "fluxhook-prod",
  ])
}

// api and auth were created by hand before the move from tau-ceti.
import {
  to = module.dns.cloudflare_dns_record.public_ingress["api"]
  id = "${local.zone_id}/d09c57759d7b3e867ad1231ff2de5218"
}

import {
  to = module.dns.cloudflare_dns_record.public_ingress["auth"]
  id = "${local.zone_id}/b4427b88997191236f6056a63a9537a4"
}
