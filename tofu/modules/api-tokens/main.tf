resource "cloudflare_account_token" "cert_manager" {
  account_id = var.account_id
  name       = "maroonrides cert-manager DNS01"

  policies = [
    {
      effect = "allow"
      permission_groups = [
        { id = "4755a26eedb94da69e1066d98aa820be" }, # DNS Write
        { id = "c8fed203ed3043cba015a93ad1616f1f" }, # Zone Read
      ]
      resources = jsonencode({
        "com.cloudflare.api.account.zone.${var.zone_id}" = "*"
      })
    }
  ]
}

resource "onepassword_item" "cf_cert_manager" {
  vault    = var.vault_uuid
  title    = "cf-cert-manager"
  category = "password"

  section_map = {
    "credentials" = {
      field_map = {
        "token" = {
          type  = "CONCEALED"
          value = cloudflare_account_token.cert_manager.value
        }
      }
    }
  }
}
