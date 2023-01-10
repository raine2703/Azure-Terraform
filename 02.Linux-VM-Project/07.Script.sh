#cloud-config
package_upgrade: true
packages:
  - nginx
runcmd:
  - cd /var/www
#Chmod 757 sets permissions so that, (U)ser / owner can read, can write and can execute.
  - sudo chmod 0757 html
