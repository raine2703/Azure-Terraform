//Copy File to Linux VM

//Use null resource when you don't have resource to associate with Azure. Just want to run someting.
resource "null_resource" "addfiles" {
//The file provisioner copies files or directories from the machine running Terraform to the newly created resource. 
provisioner "file" {
  source      = "Default.html"
  destination = "/var/www/html/Default.html"

      connection {
        type="ssh"
        user=local.vm_username
        //File () reads content of file and returns it as string
        private_key = file("${local_file.linuxpemkey.filename}")
        host ="${azurerm_public_ip.Public-IP.ip_address}"
      }
    }
    depends_on = [
      local_file.linuxpemkey,
      azurerm_linux_virtual_machine.virtual-machine
    ]
}
