# provider vars
variable "username" {
  description = "openstack username for provider auth"
}

variable "password" {
  description = "openstack password for provider auth"
}

variable "tenant_name" {
  description = "openstack project name"
}

# instance vars
variable "image_id" {
  type = string
}

variable "flavor_name" {
  type = string
}

variable "master_node_names" {
  type = set(string)
}

variable "worker_node_names" {
  type = set(string)
}

variable "lb_names" {
  type = set(string)
}

# network vars
variable "network_prefix" {
  type = string
}

variable "secgroup_prefix" {
  type = string
}

variable "ext_ports" {
  type = map(object({
    min      = number
    max      = number
    protocol = string
  }))
}

variable "int_ports" {
  type = map(object({
    min      = number
    max      = number
    protocol = string
  }))
}
