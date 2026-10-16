resource "cloudflare_dns_record" "public_ingress" {
  for_each = var.hosts

  zone_id = var.zone_id
  name    = each.value
  type    = "A"
  content = var.public_ingress_ipv4
  comment = "Public ingress on prod-server. Managed by Tofu."
  proxied = false
  ttl     = 300
}
