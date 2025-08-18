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
    name      = "gateway-ip-config"
    subnet_id = var.app_gateway_subnet_id
  }

  frontend_port {
    name = "http-port"
    port = 80
  }

  frontend_port {
    name = "https-port"
    port = 443
  }

  frontend_ip_configuration {
    name                 = "frontend-ip"
    public_ip_address_id = var.public_ip_id
  }

  backend_address_pool {
    name = "easyshop-backend-pool"
  }

  backend_http_settings {
    name                  = "easyshop-http-settings"
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 60
  }

  probe {
    name                = "easyshop-health-probe"
    protocol            = "Http"
    path                = "/"
    host                = "127.0.0.1"
    interval            = 30
    timeout             = 30
    unhealthy_threshold = 3

    match {
      status_code = ["200-399"]
    }
  }

  http_listener {
    name                           = "http-listener"
    frontend_ip_configuration_name = "frontend-ip"
    frontend_port_name             = "http-port"
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = "basic-rule"
    rule_type                  = "Basic"
    priority                   = 100
    http_listener_name         = "http-listener"
    backend_address_pool_name  = "easyshop-backend-pool"
    backend_http_settings_name = "easyshop-http-settings"
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
}