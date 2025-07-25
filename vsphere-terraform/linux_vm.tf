data "vsphere_virtual_machine" "linux_template" {
  name          = var.server_template
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

resource "vsphere_virtual_machine" "linux_vm" {
  name             = "jump"
  folder           = var.folder_name
  resource_pool_id = data.vsphere_compute_cluster.cluster.resource_pool_id
  datastore_id     = data.vsphere_datastore.datastore.id

  num_cpus   = 8
  memory     = 16384
  guest_id   = data.vsphere_virtual_machine.jump_template.guest_id
  firmware   = data.vsphere_virtual_machine.jump_template.firmware
  cdrom {
    client_device = true
  }

  network_interface {
    network_id      = var.public_network_id 
    adapter_type    = "vmxnet3"
  }

  disk {
    label            = "disk0"
    size             = data.vsphere_virtual_machine.jump_template.disks.0.size
    eagerly_scrub    = false
    thin_provisioned = false
  }

  clone {
    template_uuid = data.vsphere_virtual_machine.jump_template.id
  }
}

