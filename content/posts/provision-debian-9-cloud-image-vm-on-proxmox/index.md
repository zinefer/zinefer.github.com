+++
date = "2020-03-11T12:54:00-06:00"
title = "Provision Debian 9 cloud image VM on Proxmox"
description = "A quick guide to provision a Debain Stretch cloud-init VM on Proxmox 6"
categories = "Software"
tags = ["Proxmox", "System Administration", "Terraform"]
+++

# Download Debian 9 cloud image (openstack)

Note: You should be able to substitute any cloud-init image in this guide such as [Ubuntu Bionic](https://cloud-images.ubuntu.com/bionic/current/bionic-server-cloudimg-amd64.img).

On the proxmox host, run

```bash
cd ~
wget https://cdimage.debian.org/cdimage/openstack/current-9/debian-9-openstack-amd64.qcow2
```

Create a vm that will be used to capture a template

```bash
qm create 1000 --name debian-cloud-image --memory 1024 --net0 virtio,bridge=vmbr0 --cores 1 --sockets 1 --cpu cputype=kvm64 --description "Debian 9 cloud-image" --kvm 1 --numa 1
qm importdisk 1000 debian-9-openstack-amd64.qcow2 local-lvm
qm set 1000 --scsihw virtio-scsi-pci --scsi0 local-lvm:vm-1000-disk-0
qm set 1000 --ide2 local-lvm:cloudinit
qm set 1000 --boot c --bootdisk scsi0
qm set 1000 --serial0 socket --vga serial0
# Convert to a template
qm template 1000
```

_Note: The vmid (1000) and storage locations (local-lvm) can be changed to suit your needs_

# Creating a VM from our template

```bash
qm clone 1000 101 --name vmtest
qm set 101 --name vmtest
qm set 101 --net0 model=virtio,bridge=vmbr0
qm set 101 --ipconfig0 ip=10.0.0.5/32,gw=10.0.0.1
qm set 123 --sshkey ~/.ssh/id_rsa.pub
qm set 101 --onboot 1
qm start 101
```

# Creating a VM from our template with Terraform

If you happen to need to accomplish this with [Terraform](//github.com/Telmate/terraform-provider-proxmox) I've got you covered.

```tf
resource "proxmox_vm_qemu" "vm" {
  name        = var.name
  target_node = "proxmox"
  clone       = "debian-cloud-image"

  disk {
    id       = 0
    size     = 2
    type     = "virtio"
    iothread = true
    storage  = "vdisk"
    storage_type = "lvm"
  }

  ssh_user  = "root"
  ipconfig0 = "ip=10.0.0.5/32,gw=10.0.0.1"
  sshkeys   = <<EOF
  ssh-rsa public key for ssh
  EOF
}
```