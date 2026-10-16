variable "zone_id" {
  type = string
}

variable "public_ingress_ipv4" {
  type = string
}

variable "hosts" {
  description = "Subdomains that point at the public ingress"
  type        = set(string)
}
