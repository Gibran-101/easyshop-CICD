# Application Gateway Module

## Overview
Creates an Azure Application Gateway with Web Application Firewall (WAF) capabilities, SSL termination, and auto-scaling for production e-commerce workloads. This module provides enterprise-grade Layer 7 load balancing with integrated security features.

## Purpose
- **Layer 7 Load Balancing**: Intelligent traffic routing based on HTTP/HTTPS
- **SSL Termination**: Centralized certificate management and HTTPS handling
- **Web Application Firewall**: Protection against OWASP Top 10 vulnerabilities
- **Auto-scaling**: Automatic capacity adjustment based on traffic demand
- **Health Monitoring**: Continuous backend health checks and failover

## Features
- ✅ **Production-ready configuration** with auto-scaling
- ✅ **SSL/TLS termination** with modern security policies
- ✅ **HTTP to HTTPS redirect** for security compliance
- ✅ **Health probes** for backend monitoring
- ✅ **WAF protection** against common attacks
- ✅ **Connection draining** for graceful deployments
- ✅ **SNI support** for multiple domains

## Usage

### Basic Setup
```hcl
module "application_gateway" {
  source = "./modules/application-gateway"
  
  project_name            = "easyshop"
  resource_group_name     = "easyshop-rg"
  location               = "East US"
  app_gateway_subnet_id  = module.networking.app_gateway_subnet_id
  public_ip_id           = azurerm_public_ip.ingress_ip.id
  dns_zone_name          = "buildandship.space"
  
  tags = {
    Environment = "production"
    Project     = "EasyShop"
  }
}
```

### Production Setup with WAF
```hcl
module "application_gateway" {
  source = "./modules/application-gateway"
  
  project_name            = "easyshop"
  resource_group_name     = "easyshop-rg"
  location               = "East US"
  app_gateway_subnet_id  = module.networking.app_gateway_subnet_id
  public_ip_id           = azurerm_public_ip.ingress_ip.id
  dns_zone_name          = "buildandship.space"
  
  # Enable WAF for security
  sku_tier   = "WAF_v2"
  enable_waf = true
  
  # Production auto-scaling
  autoscale_config = {
    min_capacity = 2
    max_capacity = 10
  }
  
  # Custom health check
  health_probe_config = {
    path                = "/health"
    interval            = 15
    timeout             = 15
    unhealthy_threshold = 2
    status_codes        = ["200"]
  }
  
  tags = {
    Environment = "production"
    Project     = "EasyShop"
  }
}
```

## Integration with AKS

This module is designed to work with Azure Application Gateway Ingress Controller (AGIC) for seamless Kubernetes integration:

1. **AGIC** monitors Kubernetes Ingress resources
2. **Automatically configures** Application Gateway backend pools
3. **Manages SSL certificates** and routing rules
4. **Provides native Azure integration** without additional pods

## SSL Certificate Management

### Initial Setup
- Module creates a **temporary self-signed certificate** for initial deployment
- **Replace with proper certificates** using one of these methods:

### Option 1: Let's Encrypt with cert-manager
```yaml
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: easyshop-ssl
spec:
  secretName: easyshop-tls
  issuerRef:
    name: letsencrypt-prod
    kind: ClusterIssuer
  dnsNames:
  - buildandship.space
```

### Option 2: Azure Key Vault certificates
```hcl
variable "key_vault_id" {
  description = "Key Vault ID for SSL certificates"
  type        = string
}

# Reference in ssl_certificate block
ssl_certificate {
  name               = "easyshop-ssl-cert"
  key_vault_secret_id = azurerm_key_vault_certificate.ssl.secret_id
}
```

## Security Features

### Web Application Firewall (WAF)
- **OWASP Core Rule Set 3.2** protection
- **Prevention mode** blocks malicious requests
- **Customizable rules** for application-specific needs
- **Request body inspection** up to 128KB

### SSL Policy
- **TLS 1.2+** only (modern security standards)
- **Strong cipher suites** for perfect forward secrecy
- **HSTS support** for enhanced security

## Monitoring & Troubleshooting

### Health Checks
```bash
# Check Application Gateway status
az network application-gateway show \
  --name easyshop-app-gateway \
  --resource-group easyshop-rg

# View backend health
az network application-gateway show-backend-health \
  --name easyshop-app-gateway \
  --resource-group easyshop-rg
```

### Common Issues
- **Backend unhealthy**: Check AKS pod status and health endpoint
- **SSL certificate errors**: Verify certificate format and password
- **WAF blocking requests**: Review WAF logs and adjust rules
- **High latency**: Check backend response times and auto-scaling

### Performance Optimization
- **Connection draining**: Enabled for zero-downtime deployments
- **Auto-scaling**: Responds to traffic patterns automatically
- **Health probes**: Ensures traffic only goes to healthy backends
- **SSL offloading**: Reduces load on backend pods

## Cost Optimization
- **Standard_v2 tier** for cost-effective operation
- **Auto-scaling** prevents over-provisioning
- **Shared public IP** reduces additional costs
- **Efficient health checks** minimize backend load

## Future Enhancements
- **Multiple backend pools** for microservices
- **Path-based routing** for API versioning
- **Custom error pages** for better UX
- **Advanced WAF rules** for specific threats
- **Multi-region deployment** for global availability

## Dependencies
- Azure VNet with dedicated subnet
- Public IP address for frontend
- Azure DNS zone for domain management
- AKS cluster for backend services