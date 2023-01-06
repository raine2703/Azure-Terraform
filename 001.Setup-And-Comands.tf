Terraform Set Up - Download Terraform, Add Environment variable in Windows, Choose provider and Start using Terraform!
Terraform as application must be registered in AAD. Also it must be granted necessary RBAC permissions on Subscription level. Contributor as example.

terrafrom init
terraform -version
terraform -validate
terraform plan -out main.tfplan
terraform plan -out main.tfplan -var="number-of-subnets=3"
terraform apply 
terraform apply main.tfplan   - defines plan we created before
terraform destroy

 Showing outputs. 
output "SubnetA-ID" {
  value = azurerm_subnet.SubnetA.id
}


