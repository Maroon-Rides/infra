// Records are written by external-dns from the HTTPRoutes; these stay in
// Cloudflare and external-dns adopts them.
removed {
  from = module.dns

  lifecycle {
    destroy = false
  }
}
