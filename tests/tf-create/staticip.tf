# variables that can be overriden
variable "hostname" { default="staticip" }
variable "password" { default="linux" }
variable "dns_domain" { default="my.test"  }
variable "ip_type" { default = "static" } # dhcp is other valid type
variable "memoryMB" { default = 1024*1 }
variable "cpu" { default = 1 }
variable "prefixIP" { default = "192.168.122" }
variable "ubuntuCodeName" { default = "bionic" }


locals {
  ubuntu_versions = { 
    "xenial2" = { code_name = "xenial", octetIP = "200" },
    "bionic2" = { code_name = "bionic", octetIP = "201" },
    "focal2"  = { code_name = "focal",  octetIP = "202" },
  }
}

terraform { 
  required_version = ">= 0.12"
}

# instance the provider
provider "libvirt" {
  uri = "qemu:///system"
}

# fetch the latest ubuntu release image from their mirrors
resource "libvirt_volume" "os_image" {
  for_each = local.ubuntu_versions

  name = "${each.key}-os_image"
  pool = "default"
  source = "https://cloud-images.ubuntu.com/${each.value.code_name}/current/${each.value.code_name}-server-cloudimg-amd64${ each.value.code_name == "xenial" ? "-disk1":"" }.img"
  format = "qcow2"
}

# Use CloudInit ISO to add ssh-key to the instance
resource "libvirt_cloudinit_disk" "commoninit" {
  for_each = local.ubuntu_versions

  name = "${each.key}-commoninit.iso"
  pool = "default"
  user_data = data.template_file.user_data[each.key].rendered
  network_config = data.template_file.network_config[each.key].rendered
}


data "template_file" "user_data" {
  for_each = local.ubuntu_versions

  template = file("${path.module}/cloud_init.cfg")
  vars = {
    hostname = each.key
    fqdn = "${each.key}.${var.dns_domain}"
    password = "${var.password}"
  }
}

data "template_file" "network_config" {
  for_each = local.ubuntu_versions

  template = file("${path.module}/network_config_${var.ip_type}.cfg")
  vars = {
    domain = var.dns_domain
    prefixIP = var.prefixIP
    octetIP = each.value.octetIP
  }
}


# Create the machine
resource "libvirt_domain" "domain-ubuntu" {
  for_each = local.ubuntu_versions

  # domain name in libvirt, not hostname
  name = "${each.key}-${var.prefixIP}.${each.value.octetIP}"
  memory = var.memoryMB
  vcpu = var.cpu

  disk {
       volume_id = libvirt_volume.os_image[each.key].id
  }
  network_interface {
       network_name = "default"
       addresses = [ "${var.prefixIP}.${each.value.octetIP}" ]
  }

  cloudinit = libvirt_cloudinit_disk.commoninit[each.key].id

  # IMPORTANT
  # Ubuntu can hang is a isa-serial is not present at boot time.
  # If you find your CPU 100% and never is available this is why
  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }

  graphics {
    type = "spice"
    listen_type = "address"
    autoport = "true"
  }
}


output "hosts" {
  # output does not support 'for_each', so use zipmap as workaround
  value = zipmap( 
                values(libvirt_domain.domain-ubuntu)[*].name,
                values(libvirt_domain.domain-ubuntu)[*].network_interface.0.addresses
                )
}
