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
  address = "https://localhost:8200"
  skip_tls_verify = true
  alias = "root"
}

resource "vault_namespace" var.namespace_name {
  path = var.namespace_name
  provider = vault.root
}

provider "vault" {
  version = "~> 2.11"
  address = "https://localhost:8200"
  skip_tls_verify = true
  alias = "ns"
  namespace = var.namespace_name
}

resource "vault_policy" "admin_policy" {
  name = "admins"
  policy = file("policies/admin.hcl")
  provider = vault.ns
}
resource "vault_policy" "provisioner_policy" {
  name = "provisioners"
  policy = file("policies/provisioner.hcl")
  provider = vault.ns
}
resource "vault_policy" "user_policy" {
  name = "users"
  policy = file("policies/user.hcl")
  provicer = vault.ns
}

resource "vault_ldap_auth_backend" "ldap" {
    depends_on  = [ vault_namespace.ns1 ]
    path        = "${vault_namespace.ns1.path}-ldap"
    url         = "ldaps://dc-01.example.org"
    userdn      = "OU=Users,OU=Accounts,DC=example,DC=org"
    userattr    = "sAMAccountName"
    upndomain   = "EXAMPLE.ORG"
    discoverdn  = false
    groupdn     = "OU=Groups,DC=example,DC=org"
    groupfilter = "(&(objectClass=group)(member:1.2.840.113556.1.4.1941:={{.UserDN}}))"
    provider = vault.ns1
}
