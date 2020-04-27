# network section
variable "v4_network_name" {
  type    = string
  default = "rap-ip4-network"
}

variable "v6_network_name" {
  type    = string
  default = "rap-ip6-network"
}

# instance section
variable "master_instance_names" {
  type = set(string)
  default = [
    "rap_master_1"
  ]
}

variable "worker_instance_names" {
  type = set(string)
  default = [
    "rap_worker_1"
  ]
}

variable "lb_instance_names" {
  type = set(string)
  default = [
    "rap_load_balancer"
  ]
}

variable "image_id" {
  type    = string
  default = "41c4c9fc-c8d7-4475-8989-8103b0484128"
}

variable "flavor_name" {
  type    = string
  default = "c1.2"
}

