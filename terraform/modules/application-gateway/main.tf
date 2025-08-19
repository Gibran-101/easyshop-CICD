resource "azurerm_application_gateway" "this" {
  name                = "${var.project_name}-app-gateway"
  resource_group_name = var.resource_group_name
  location            = var.location

  sku {
    name = var.sku_tier
    tier = var.sku_tier
  }

  autoscale_configuration {
    min_capacity = var.autoscale_config.min_capacity
    max_capacity = var.autoscale_config.max_capacity
  }

  gateway_ip_configuration {
    name      = "appGatewayIpConfig"
    subnet_id = var.app_gateway_subnet_id
  }

  frontend_ip_configuration {
    name                 = "appGwPublicFrontendIp"
    public_ip_address_id = var.public_ip_id
  }

  frontend_port {
    name = "port_80"
    port = 80
  }

  frontend_port {
    name = "port_443"
    port = 443
  }

  # MINIMAL required backend (AGIC will add more)
  backend_address_pool {
    name = "defaultaddresspool"
  }

  backend_http_settings {
    name                  = "defaulthttpsetting"
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 20
  }

  http_listener {
    name                           = "defaulthttplistener"
    frontend_ip_configuration_name = "appGwPublicFrontendIp"
    frontend_port_name             = "port_80"
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = "defaultrule"
    rule_type                  = "Basic"
    priority                   = 1
    http_listener_name         = "defaulthttplistener"
    backend_address_pool_name  = "defaultaddresspool"
    backend_http_settings_name = "defaulthttpsetting"
  }

  dynamic "waf_configuration" {
    for_each = var.enable_waf ? [1] : []
    content {
      enabled           = true
      firewall_mode     = "Prevention"
      rule_set_type     = "OWASP"
      rule_set_version  = "3.2"
    }
  }

  tags = var.tags

  # Let AGIC manage dynamic resources
  lifecycle {
    ignore_changes = [
      backend_address_pool,
      backend_http_settings,
      probe,
      http_listener,
      request_routing_rule,
      ssl_certificate,
    ]
  }
}

# Create managed identity for AGIC
resource "azurerm_user_assigned_identity" "agic_identity" {
  name                = "${var.project_name}-agic-identity"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

# Give AGIC permission to manage App Gateway
resource "azurerm_role_assignment" "agic_app_gateway_contributor" {
  scope                = azurerm_application_gateway.this.id
  role_definition_name = "Contributor"
  principal_id         = azurerm_user_assigned_identity.agic_identity.principal_id
}