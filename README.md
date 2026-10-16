# infra

MaroonRides infrastructure: one Contabo VPS (`prod-server`) running NixOS and a
single-node k3s cluster (`prod`) reconciled by Flux.

- `tofu/`: Contabo instance + NixOS install, `maroonrides.app` DNS records,
  Cloudflare tokens, R2 backup bucket, Tailscale policy, Flux webhooks
- `nixos/`: host configuration
- `kubernetes/`: Flux tree. `apps/base` is the platform, `apps/prod` the apps

## Tofu

State is `infra.tfstate` in the `maroonrides-tofu-state` R2 bucket. `tofu/.env`
(loaded by mise) holds `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY` and
`OP_ACCOUNT`. CI uses `OP_SERVICE_ACCOUNT_TOKEN` instead of `OP_ACCOUNT`.

Item `tofu-credentials` in the `Maroon Rides Deployment` 1Password vault:

| Section      | Fields                                               | Permissions                                                                  |
| ------------ | ---------------------------------------------------- | ---------------------------------------------------------------------------- |
| `cloudflare` | `api_token`                                          | Account: API Tokens Edit, Workers R2 Storage Edit; zone: Zone Read, DNS Edit |
| `github`     | `token`                                              | `Maroon-Rides/infra`: Webhooks read/write                                    |
| `contabo`    | `client_id`, `client_secret`, `username`, `password` | Contabo API                                                                  |
| `tailscale`  | `client_id`, `client_secret`                         | OAuth client, all scopes                                                     |

## Bring-up

1. Create the `maroonrides-tofu-state` R2 bucket and the `tofu-credentials` item
2. `tofu apply -target=module.contabo.contabo_instance.prod_server`
3. Fill `nixos/hosts/prod-server/addresses.nix` from the Contabo panel
4. `tofu apply` installs NixOS through nixos-anywhere and creates everything else
5. `ssh maroonrides@<ip> sudo tailscale up`
6. Set `PUBLIC_IPV4` in `kubernetes/clusters/prod/kustomization.yaml`, push
7. Create a 1Password Connect server for the vault, saved as item `1password-connect`
8. `mise run bootstrap prod-server`

## Migrating from homelab

api and auth run on both servers until DNS flips; tau-ceti keeps serving them.

1. Scale `maroonrides-api` to 0 on tau-ceti, `pg_dump` the database
2. Restore the dump into `maroonrides-db` on prod
3. Add `api` and `auth` to `public_ingress_hosts` in `tofu/config/dns.tf`, apply
4. Remove `kubernetes/apps/tau-ceti/maroonrides` from homelab
