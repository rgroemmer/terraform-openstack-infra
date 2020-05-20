output "lb_public_ip" {
  value = openstack_compute_floatingip_v2.fip.address
}

output "master_ipv6_addresses" {
  value = [for instance in openstack_compute_instance_v2.master_nodes : instance.access_ip_v6]
}
