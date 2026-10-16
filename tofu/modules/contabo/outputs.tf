output "public_ipv4" {
  value = contabo_instance.prod_server.ip_config[0].v4[0].ip
}
