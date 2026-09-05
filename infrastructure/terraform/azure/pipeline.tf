data "azurerm_user_assigned_identity" "pipeline" {
  name                = "github-actions-cloud-platform"
  resource_group_name = "rg-cloud-platform-identity"
}

resource "azurerm_role_assignment" "pipeline_acr_push" {
  scope                = azurerm_container_registry.cloud_platform.id
  role_definition_name = "AcrPush"
  principal_id         = data.azurerm_user_assigned_identity.pipeline.principal_id
}