# Network creation section
resource "openstack_networking_network_v2" "network_ip4" {
  name           = var.v4_network_name
  admin_state_up = "true"
}

resource "openstack_networking_network_v2" "network_ip6" {
  name           = var.v6_network_name
  admin_state_up = "true"
}

# Subnet creation section
resource "openstack_networking_subnet_v2" "subnet_ip4" {
  name            = "subnet_ip4"
  network_id      = openstack_networking_network_v2.network_ip4.id
  cidr            = "192.168.42.0/24"
  dns_nameservers = ["8.8.8.8", "8.8.8.4"]
  ip_version      = 4
}

resource "openstack_networking_subnet_v2" "subnet_ip6" {
  name              = "subnet_ip6"
  network_id        = openstack_networking_network_v2.network_ip6.id
  cidr              = "2001:cafe::/64"
  ip_version        = 6
  ipv6_address_mode = "dhcpv6-stateful"
  ipv6_ra_mode      = "dhcpv6-stateful"
}

# data resource to get id for existing network
data "openstack_networking_network_v2" "floating_net" {
  name = "floating-net"
}

# Router creation section
resource "openstack_networking_router_v2" "generic_v4" {
  name                = "router-generic_v4"
  external_network_id = data.openstack_networking_network_v2.floating_net.id
}

resource "openstack_networking_router_v2" "generic_v6" {
  name = "router-generic_v6"
}

resource "openstack_networking_router_interface_v2" "router_interface_v4" {
  router_id = openstack_networking_router_v2.generic_v4.id
  subnet_id = openstack_networking_subnet_v2.subnet_ip4.id
}

resource "openstack_networking_router_interface_v2" "router_interface_v6" {
  router_id = openstack_networking_router_v2.generic_v6.id
  subnet_id = openstack_networking_subnet_v2.subnet_ip6.id
}

# floating-ip creation
resource "openstack_compute_floatingip_v2" "fip" {
  pool = "floating-net"
}

resource "openstack_compute_floatingip_associate_v2" "fip_associate" {
  for_each    = var.lb_instance_names
  floating_ip = openstack_compute_floatingip_v2.fip.address
  instance_id = openstack_compute_instance_v2.ske_lbs[each.key].id
}

# instance section
resource "openstack_compute_instance_v2" "ske_master" {
  for_each  = var.master_instance_names
  name      = each.key
  image_id  = "41c4c9fc-c8d7-4475-8989-8103b0484128"
  flavor_id = "5fe737c2-18d8-43c6-bb11-dc9c97ff9515"
  key_pair  = "ske-key"

  block_device {
    uuid                  = "41c4c9fc-c8d7-4475-8989-8103b0484128"
    source_type           = "image"
    destination_type      = "volume"
    boot_index            = 0
    volume_size           = 20
    delete_on_termination = true
  }

  network {
    name = openstack_networking_network_v2.network_ip4.name
  }

  network {
    name = openstack_networking_network_v2.network_ip6.name
  }
}

resource "openstack_compute_instance_v2" "ske_worker" {
  for_each  = var.worker_instance_names
  name      = each.key
  image_id  = "41c4c9fc-c8d7-4475-8989-8103b0484128"
  flavor_id = "5fe737c2-18d8-43c6-bb11-dc9c97ff9515"
  key_pair  = "ske-key"

  block_device {
    uuid                  = "41c4c9fc-c8d7-4475-8989-8103b0484128"
    source_type           = "image"
    destination_type      = "volume"
    boot_index            = 0
    volume_size           = 20
    delete_on_termination = true
  }

  network {
    name = openstack_networking_network_v2.network_ip4.name
  }

  network {
    name = openstack_networking_network_v2.network_ip6.name
  }
}

resource "openstack_compute_instance_v2" "ske_lbs" {
  for_each  = var.lb_instance_names
  name      = each.key
  image_id  = "41c4c9fc-c8d7-4475-8989-8103b0484128"
  flavor_id = "5fe737c2-18d8-43c6-bb11-dc9c97ff9515"
  key_pair  = "ske-key"

  block_device {
    uuid                  = "41c4c9fc-c8d7-4475-8989-8103b0484128"
    source_type           = "image"
    destination_type      = "volume"
    boot_index            = 0
    volume_size           = 20
    delete_on_termination = true
  }

  network {
    name = openstack_networking_network_v2.network_ip4.name
  }

  network {
    name = openstack_networking_network_v2.network_ip6.name
  }
}

output "fip" {
  value = openstack_compute_floatingip_v2.fip.address
}

