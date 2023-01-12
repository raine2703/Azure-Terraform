//Creating azure service plan, web app, deployment slot and enabled server logging

//Creating S1 Service plan.  Deployment slots available starting from S1 tier.
resource "azurerm_service_plan" "ServicePlan" {
  name                = local.service_plan_name
  resource_group_name = local.resource_group_name
  location            = local.location
  os_type             = local.os_type
  sku_name            = local.service_plan_sku
  depends_on = [
    azurerm_resource_group.resource-group
  ]
}

//Creating Web App
resource "azurerm_windows_web_app" "WebAppRn2703" {
  name                = local.web_app_name
  resource_group_name = local.resource_group_name
  location            = local.location
  service_plan_id     = azurerm_service_plan.ServicePlan.id

  site_config {
    application_stack {
        current_stack = "dotnet"
        dotnet_version = "v6.0"
    }
//Testing networking options. Denying all tyraffic to WebAppRn2703
      ip_restriction{
        action="Deny"
        ip_address="0.0.0.0/0"
        name="Deny_AllTraffic"
        priority =200 
      }
  }
  
//Enabling Web server logs. Connection with shared access signature.
  logs {
    detailed_error_messages = true
  http_logs {    
    azure_blob_storage {        
        retention_in_days=7   
        sas_url =  "https://${azurerm_storage_account.storage-account.name}.blob.core.windows.net/${azurerm_storage_container.logs.name}${data.azurerm_storage_account_blob_container_sas.accountsas.sas}"
    }
  }
}

//Enabling application insights. Defining where to send logs. Multiple settings needed to be enabled and definded for monitoring to work. Requirments changes over time.
app_settings = {
  //"APPINSIGHTS_INSTRUMENTATIONKEY" = azurerm_application_insights.appinsights.instrumentation_key
  // "APPLICATIONINSIGHTS_CONNECTION_STRING" = azurerm_application_insights.appinsights.connection_string
    "MSDEPLOY_RENAME_LOCKED_FILES"                    = "1"
    "WEBSITE_HEALTHCHECK_MAXPINGFAILURES"             = "10"
    "ASPNETCORE_ENVIRONMENT"                          = "Development"
    "APPINSIGHTS_INSTRUMENTATIONKEY"                  = azurerm_application_insights.appinsights.instrumentation_key
    "APPLICATIONINSIGHTS_CONNECTION_STRING"           = azurerm_application_insights.appinsights.connection_string
    "APPINSIGHTS_PROFILERFEATURE_VERSION"             = "1.0.0"
    "APPINSIGHTS_SNAPSHOTFEATURE_VERSION"             = "1.0.0"
    "ApplicationInsightsAgent_EXTENSION_VERSION"      = "~2"
    "DiagnosticServices_EXTENSION_VERSION"            = "~3"
    "InstrumentationEngine_EXTENSION_VERSION"         = "disabled"
    "SnapshotDebugger_EXTENSION_VERSION"              = "disabled"
    "XDT_MicrosoftApplicationInsights_BaseExtensions" = "disabled"
    "XDT_MicrosoftApplicationInsights_Java"           = "1"
    "XDT_MicrosoftApplicationInsights_Mode"           = "recommended"
    "XDT_MicrosoftApplicationInsights_NodeJS"         = "1"
    "XDT_MicrosoftApplicationInsights_PreemptSdk"     = "disabled"
}
  depends_on = [
    azurerm_service_plan.ServicePlan
  ]
}
