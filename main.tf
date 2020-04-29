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

# secgroup creation
resource "openstack_networking_secgroup_v2" "securitygroup" {
  name = "ske-securitygroup"
}

resource "openstack_networking_secgroup_rule_v2" "secgroup_rule_ssh_v4" {
  description       = "Allow SSH"
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.securitygroup.id
}

resource "openstack_networking_secgroup_rule_v2" "secgroup_rule_k8s_v4" {
  description       = "Allow kube-apiserver"
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 6443
  port_range_max    = 6443
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.securitygroup.id
}

resource "openstack_networking_secgroup_rule_v2" "secgroup_rule_ssh_v6" {
  description       = "Allow SSH"
  direction         = "ingress"
  ethertype         = "IPv6"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_ip_prefix  = "::/0"
  security_group_id = openstack_networking_secgroup_v2.securitygroup.id
}

resource "openstack_networking_secgroup_rule_v2" "secgroup_rule_k8s_v6" {
  description       = "Allow kube-apiserver"
  direction         = "ingress"
  ethertype         = "IPv6"
  protocol          = "tcp"
  port_range_min    = 6443
  port_range_max    = 6443
  remote_ip_prefix  = "::/0"
  security_group_id = openstack_networking_secgroup_v2.securitygroup.id
}

# floating-ip creation
resource "openstack_compute_floatingip_v2" "fip" {
  pool = "floating-net"
}

resource "openstack_compute_floatingip_associate_v2" "fip_associate" {
  for_each    = var.lb_instance_names
  floating_ip = openstack_compute_floatingip_v2.fip.address
  instance_id = openstack_compute_instance_v2.ske_loadbalancer[each.key].id
}

# instance section
resource "openstack_compute_instance_v2" "ske_master" {
  for_each        = var.master_instance_names
  name            = each.key
  image_id        = var.image_id
  flavor_id       = data.openstack_compute_flavor_v2.flavor.id
  key_pair        = "ske-key"
  security_groups = [openstack_networking_secgroup_v2.securitygroup.id]

  block_device {
    uuid                  = var.image_id
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
  for_each        = var.worker_instance_names
  name            = each.key
  image_id        = var.image_id
  flavor_id       = data.openstack_compute_flavor_v2.flavor.id
  key_pair        = "ske-key"
  security_groups = [openstack_networking_secgroup_v2.securitygroup.id]

  block_device {
    uuid                  = var.image_id
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

resource "openstack_compute_instance_v2" "ske_loadbalancer" {
  for_each        = var.lb_instance_names
  name            = each.key
  image_id        = var.image_id
  flavor_id       = data.openstack_compute_flavor_v2.flavor.id
  key_pair        = "ske-key"
  security_groups = [openstack_networking_secgroup_v2.securitygroup.id]

  block_device {
    uuid                  = var.image_id
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

resource "null_resource" "provisioner" {
  depends_on = [openstack_compute_floatingip_associate_v2.fip_associate]
  connection {
    type        = "ssh"
    host        = openstack_compute_floatingip_v2.fip.address
    user        = "ubuntu"
    private_key = file("/home/groemmer/terraform-openshift/ssh-key/ske-key")
    timeout     = "5m"
  }

  provisioner "file" {
    content = templatefile("config/nginx.tmpl", {
      ip_addrs = [for instance in openstack_compute_instance_v2.ske_master : instance.access_ip_v6],
      port     = 6443
    })
    destination = "/tmp/nginx.conf"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get install -y nginx",
      "sudo apt-get install -y nginx libnginx-mod-stream",
      "sudo mv /tmp/nginx.conf /etc/nginx/nginx.conf",
      "sudo systemctl restart nginx",
      "sleep 20",
    ]
  }
}

data "openstack_compute_flavor_v2" "flavor" {
  name = var.flavor_name
}

output "fip" {
  value = openstack_compute_floatingip_v2.fip.address
}

output "ip_v6" {
  value = [for instance in openstack_compute_instance_v2.ske_master : instance.access_ip_v6]
}
