//Creating Linux VM with SSH key.
//To log in: ssh -i .\linuxkey.pem adminuser@20.223.183.94
//Installing nginx with custom script

//Generate key for linux vm
resource "tls_private_key" "linuxkey" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

//Stores the key in linuxkey.pem file to be able to log in. NOT RECOMENDED FOR PRODUCTION.
resource "local_file" "linuxpemkey"{
  filename = "linuxkey.pem"
  content=tls_private_key.linuxkey.private_key_pem
  depends_on = [
    tls_private_key.linuxkey
  ]
}

//Defining location for Script to install Nginx on Linux VM
//Data sources allow Terraform to use information defined outside of Terraform
data "template_file" "cloudinitdata" {
    template = file("script.sh")
}

//Creating Linux VM
resource "azurerm_linux_virtual_machine" "virtual-machine" {
  name                = local.vm_name
  resource_group_name = local.resource_group_name
  location            = local.location
  size                = local.vm_size
  admin_username      = local.vm_username
  //Script must be base64 encoded and value rendered
  custom_data         = base64encode(data.template_file.cloudinitdata.rendered)
  network_interface_ids = [
    azurerm_network_interface.vm1nic.id,
  ]

  admin_ssh_key {
    username   = local.vm_username
    public_key = tls_private_key.linuxkey.public_key_openssh
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = local.vm_storage_account_type
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts"
    version   = "latest"
  }
  depends_on = [
    azurerm_network_interface.vm1nic,
    tls_private_key.linuxkey
  ]
}
