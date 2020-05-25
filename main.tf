provider "vault" {
  version = "~> 2.11"
  #  auth_login {
  #    path = "auth/approle/login"
  #
  #    parameters = {
  #      role_id   = var.login_approle_role_id
  #      secret_id = var.login_approle_secret_id
  #    }
  #  }
  address         = var.provider_url
  skip_tls_verify = true
  alias           = "root"
}

resource "vault_namespace" "namespace" {
  path     = var.namespace_name
  provider = vault.root
}

provider "vault" {
  version         = "~> 2.11"
  address         = provider.url
  skip_tls_verify = true
  alias           = "ns"
  namespace       = vault_namespace.namespace.path
}

resource "vault_policy" "policy" {
  for_each   = var.namespace_policies
  name       = "${each.value}"
  policy     = file("policies/${each.value}")
  depends_on = [vault_namespace.namespace]
  provider   = vault.ns
}

resource "vault_ldap_auth_backend" "ldap" {
  depends_on  = [vault_namespace.namespace]
  provider    = vault.ns
  path        = var.ldap_path
  url         = var.ldap_url
  userdn      = var.ldap_userdn
  userattr    = var.ldap_userattr
  upndomain   = var.ldap_upndomain
  discoverdn  = var.ldap_discoverdn
  groupdn     = var.ldap_groupdn
  groupfilter = var.ldap_groupfilter
}
