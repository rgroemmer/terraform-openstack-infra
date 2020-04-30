provider "openstack" {
  auth_url = "https://platform.cloud.schwarz:5000/v3"
  region   = "RegionOne"

  user_domain_name = "Default"
  user_name        = var.username
  password         = var.password

  tenant_name = var.tenant_name
}
