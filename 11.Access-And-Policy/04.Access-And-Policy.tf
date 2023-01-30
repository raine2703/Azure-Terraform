//Install azure cli and az login to be able to create/manage AAD users.
//To add RBAC role you need to have User Acceess administartor or Owner role.

//Creating usera in AAD
resource "azuread_user" "user" {
  user_principal_name = "usera2@raitisneitalsgmail.onmicrosoft.com"
  display_name        = "usera2"  
  password            = "Secret@123"
}


//Getting user name to work with it
data "azuread_user" "example" {
  user_principal_name = "usera2@raitisneitalsgmail.onmicrosoft.com"
  depends_on = [
    azuread_user.user
  ]
}

//Assigning user RBAC role to Resource group level.
resource "azurerm_role_assignment" "Reader_role" {
  scope                = azurerm_resource_group.resource-group.id
  role_definition_name = "Reader"
  principal_id         = data.azuread_user.example.object_id
  //could also use from resource block
  //principal_id         = azuread_user.userA.object_id

  depends_on = [
    azurerm_resource_group.resource-group,
    data.azuread_user.example
  ]
}

//Assigin AAD role
resource "azuread_directory_role" "example" {
  display_name = "Helpdesk administrator"
}

resource "azuread_directory_role_assignment" "example" {
  role_id             = azuread_directory_role.example.template_id
  principal_object_id = data.azuread_user.example.object_id
  depends_on = [
    data.azuread_user.example
  ]
}


//Creating custom role from RBAC. Subscription level.

  
//Getting Scope
data "azurerm_subscription" "Azuresubscription" {
}

//Creating custom role
resource "azurerm_role_definition" "customrole" {
  name        = "CustomRole"
  scope       = data.azurerm_subscription.Azuresubscription.id
  description = "This is a custom role created via Terraform"

  permissions {
    actions     = ["Microsoft.Compute/*/read",
      "Microsoft.Compute/virtualMachines/start/action",
      "Microsoft.Compute/virtualMachines/restart/action" ]
    not_actions = []
  }

  assignable_scopes = [
    data.azurerm_subscription.Azuresubscription.id
  ]
}

//Assign custom role to resource group level
resource "azurerm_role_assignment" "Custom_role_assignment" {
  scope                = azurerm_resource_group.resource-group.id
  role_definition_name = "CustomRole"
  principal_id         = data.azuread_user.example.id

  depends_on = [
    azurerm_resource_group.resource-group,
    data.azuread_user.example,
    azurerm_role_definition.customrole
  ]
}


//Policy


//Getting in built polic definition
data "azurerm_policy_definition" "allowedresourcetypes" {
  display_name = "Allowed resource types"
}

//Edditing inbuild policy definition by defining parameters, then assigning it to resource group level.
resource "azurerm_resource_group_policy_assignment" "assignpolicy" {
  name                 = "Assign-Policy"
  resource_group_id    = azurerm_resource_group.resource-group.id
  policy_definition_id = data.azurerm_policy_definition.allowedresourcetypes.id

  parameters = <<PARAMS
    {
      "listOfResourceTypesAllowed": {
        "value": ["microsoft.compute/virtualmachines"]
      }
    }
PARAMS

depends_on = [
  azurerm_resource_group.resource-group
]
}

//NB! Vm still cant be created:
//Policy allows VMs, but do not allow dependet resources like Vnet, Nic etc.
