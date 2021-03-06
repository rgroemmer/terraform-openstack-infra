resource "null_resource" "provisioner" {
  depends_on = [openstack_networking_floatingip_associate_v2.fip_associate]
  connection {
    type        = "ssh"
    host        = openstack_compute_floatingip_v2.fip.address
    user        = "ubuntu"
    private_key = file(var.private_key_path)
    timeout     = "5m"
  }

  provisioner "file" {
    content = templatefile("config/nginx.tmpl", {
      ip_addrs = [for instance in openstack_compute_instance_v2.master_nodes : instance.access_ip_v6],
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
