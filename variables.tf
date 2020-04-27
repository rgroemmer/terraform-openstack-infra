# network section
variable "v4_network_name" {
  type    = string
  default = "ske-ip4-network"
}

variable "v6_network_name" {
  type    = string
  default = "ske-ip6-network"
}

# instance section
variable "master_instance_names" {
  type = set(string)
  default = [
    "ske_master_1",
    "ske_master_2",
    "ske_master_3"
  ]
}

variable "worker_instance_names" {
  type = set(string)
  default = [
    "ske_worker_1",
    "ske_worker_2",
    "ske_worker_3"
  ]
}

variable "lb_instance_names" {
  type = set(string)
  default = [
    "ske_load_balancer"
  ]
}


