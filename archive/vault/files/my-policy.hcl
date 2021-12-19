# Normal servers have version 1 of KV mounted by default, so will need these
# paths:
path "kv/*" {
  capabilities = ["create"]
}

path "kv/foo" {
  capabilities = ["read"]
}

# Dev servers have version 2 of KV mounted by default, so will need these
# paths:
path "kv/data/*" {
  capabilities = ["create"]
}

path "kv/data/foo" {
  capabilities = ["read"]
}
