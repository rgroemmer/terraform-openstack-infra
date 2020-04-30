output "lb_public_ip" {
  value = openstack_compute_floatingip_v2.fip.address
}

output "master_ipv6_addresses" {
  value = [for instance in openstack_compute_instance_v2.ske_master : instance.access_ip_v6]
}
