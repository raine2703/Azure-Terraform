//Creating SQL server with two databases. Allowing VM1 to connect to SQL server from SubnetA. Also allowing connection from my current IP.

//Password saved at Azure KeyVault
data "azurerm_key_vault" "rkv2703x" {
  name                = "rkv2703x"
  resource_group_name = "RG2"
}

//Getting Password
data "azurerm_key_vault_secret" "dbpassword" {
  name         = "dbpassword"
  key_vault_id = data.azurerm_key_vault.rkv2703x.id
}

//My ip address for firewall rule
data "http" "ip" {
  url = "https://ifconfig.me/ip"
}

//Creating SQL server
resource "azurerm_mssql_server" "sqlserver" {
  name                         = local.sqlservername
  resource_group_name          = local.resource_group_name
  location                     = local.location
  version                      = local.version
  administrator_login          = local.dbuseraname
  administrator_login_password = data.azurerm_key_vault_secret.dbpassword.value
  depends_on = [
    azurerm_resource_group.resource-group
  ]
}

//Firewall rule to allow my connection to SQL server
resource "azurerm_mssql_firewall_rule" "rulea" {
  name             = "AllowClientIP"
  server_id        = azurerm_mssql_server.sqlserver.id
  //Using my IP for exception here. Range needed.
  start_ip_address = data.http.ip.response_body
  end_ip_address   = data.http.ip.response_body
  depends_on = [
    azurerm_mssql_server.sqlserver
  ]
}

//Adding another rule to allow connetion from SubnetA
resource "azurerm_mssql_virtual_network_rule" "virtualnetworkrule" {
  name      = "sql-vnet-rule"
  server_id = azurerm_mssql_server.sqlserver.id
  subnet_id = azurerm_subnet.SubnetA.id
}

//Creating first DB
resource "azurerm_mssql_database" "db1" {
  name           = local.db1name
  server_id      = azurerm_mssql_server.sqlserver.id
  collation      = "SQL_Latin1_General_CP1_CI_AS"
  license_type   = "LicenseIncluded"
  max_size_gb    = 1
  //Basic, S0 for standard
  sku_name       = "Basic"  
  depends_on = [
    azurerm_mssql_server.sqlserver
      ]
  
}

//Creating second DB
resource "azurerm_mssql_database" "db2" {
  name           = local.db2name
  server_id      = azurerm_mssql_server.sqlserver.id
  collation      = "SQL_Latin1_General_CP1_CI_AS"
  license_type   = "LicenseIncluded"
  max_size_gb    = 1
  sku_name       = "Basic"  
  depends_on = [
    azurerm_mssql_server.sqlserver
      ]
  
}
