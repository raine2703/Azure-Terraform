//Terraform Set Up - Download Terraform, Add Environment variable in Windows, Choose provider and Start using Terraform!
//Terraform as application must be registered in AAD. Also it must be granted necessary RBAC permissions on Subscription level. Contributor as example.

create main.tf file
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

// Terraform graph

https://www.terraform.io/cli/commands/graph

You first need to install the GraphViz tool. Add it system path.
http://www.graphviz.org/download/

terraform graph | dot -Tsvg > graph.svg
Run this command from command prompt from the terraform folder

