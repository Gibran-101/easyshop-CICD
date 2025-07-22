output "lb_public_ip_id" {
  value = azurerm_public_ip.lb_public_ip.id
}

output "lb_id" {
  value = azurerm_lb.lb.id
}
