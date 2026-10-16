locals {
  // api and auth still resolve to tau-ceti until the cutover.
  public_ingress_hosts = toset([
    "fluxhook-prod",
  ])
}
