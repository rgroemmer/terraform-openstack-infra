## instance ##
master_node_names = [
  "master_1",
  "master_2",
  "master_3"
]

worker_node_names = [
  "worker_1",
  "worker_2"
]

lb_name     = "lb_1"
image_id    = "38e194d3-16b9-43a7-af1d-9ffcaa98c746" // ubuntu_k8s_1.18.2_docker
flavor_name = "c1.2"
// key_pair_name    = ""
// private_key_path = ""

# network vars
network_prefix  = "network"
secgroup_prefix = "secgroup"
ext_ports = {
  ssh = {
    min      = 22
    max      = 22
    protocol = "tcp"
  }
}
int_ports = {
  ssh = {
    min      = 22
    max      = 22
    protocol = "tcp"
  }
}
