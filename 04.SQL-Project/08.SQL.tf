//Using sqlcmd to connect to db1 and execulte sql.sql comands. Microsoft SQL Server Management Studio must be installed to do this locally.
resource "null_resource" "database_setup" {
  provisioner "local-exec" {
      command = "sqlcmd -S ${azurerm_mssql_server.sqlserver.fully_qualified_domain_name} -U ${azurerm_mssql_server.sqlserver.administrator_login} -P ${data.azurerm_key_vault_secret.dbpassword.value} -d db1 -i sql.sql"
  }
  depends_on=[
    azurerm_mssql_database.db1
  ]
}
