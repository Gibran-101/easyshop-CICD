# DNS Module

## Overview
Creates and manages Azure DNS zones and records for hosting your domain's DNS infrastructure. This module provides comprehensive DNS management including A records, CNAME records, MX records for email, TXT records for verification, and advanced record types for complete domain configuration.

## Purpose
- Hosts authoritative DNS for your domain using Azure's global DNS infrastructure
- Creates A records pointing your domain to Azure load balancer/public IP
- Manages subdomain records for applications, APIs, and services
- Configures email routing with MX records
- Handles domain verification and security with TXT records
- Provides certificate authority authorization with CAA records

## When to Use
Use this module when you need:
- Professional DNS hosting for your domain
- Integration between your domain and Azure infrastructure
- Subdomain management for multiple applications or environments
- Email service configuration (Google Workspace, Office 365)
- Domain verification for SSL certificates and third-party services
- High-availability DNS with Azure's global network

## Dependencies
- **Static Public IP** (typically from main infrastructure or load balancer)
- **Domain ownership** - You must own the domain and be able to update nameservers
- **Resource group** (typically from networking module)

## What Depends on This Module
- **SSL certificate validation** - Let's Encrypt and other CAs use DNS for validation
- **Email services** - MX records route email to your email provider
- **Web traffic** - A records direct visitors to your applications
- **API integrations** - Subdomain records enable service discovery

## Example Usage

### Basic Setup (Single Domain)
```hcl
module "dns" {
  source               = "./modules/dns"
  project_name         = "easyshop"
  location             = "East US"
  dns_zone_name        = "buildandship.space"
  resource_group_name  = module.networking.resource_group_name
  ingress_public_ip_id = azurerm_public_ip.ingress_ip.id

  # Basic configuration
  create_www_record = true
  root_ttl         = 300

  tags = var.tags
}
```

### Production Setup (Multiple Services)
```hcl
module "dns" {
  source               = "./modules/dns"
  project_name         = "mycompany"
  location             = "East US"
  dns_zone_name        = "mycompany.com"
  resource_group_name  = module.networking.resource_group_name
  ingress_public_ip_id = azurerm_public_ip.ingress_ip.id

  # WWW redirect
  create_www_record = true

  # Application subdomains
  subdomain_records = [
    {
      name   = "api"
      target = "api-gateway.mycompany.com"
      ttl    = 300
    },
    {
      name   = "app"
      target = "mycompany.com"  # Points to main site
    },
    {
      name   = "docs"
      target = "documentation.external-service.com"
    }
  ]

  # Direct IP subdomains
  subdomain_a_records = [
    {
      name               = "status"
      target_resource_id = azurerm_public_ip.status_page.id
    }
  ]

  # Email configuration for Google Workspace
  mx_records = [
    {
      records = [
        { preference = 1,  exchange = "smtp.google.com" },
        { preference = 5,  exchange = "smtp2.google.com" },
        { preference = 10, exchange = "smtp3.google.com" }
      ]
    }
  ]

  # Domain verification and email security
  txt_records = [
    {
      name = "@"
      records = [
        "v=spf1 include:_spf.google.com ~all",
        "google-site-verification=your-verification-code"
      ]
    },
    {
      name = "_dmarc"
      records = ["v=DMARC1; p=quarantine; rua=mailto:dmarc@mycompany.com"]
    }
  ]

  # Certificate authority authorization
  caa_records = [
    { flags = 0, tag = "issue", value = "letsencrypt.org" },
    { flags = 0, tag = "issuewild", value = "letsencrypt.org" },
    { flags = 0, tag = "iodef", value = "mailto:security@mycompany.com" }
  ]

  tags = var.tags
}
```

### Development Environment Setup
```hcl
module "dns" {
  source               = "./modules/dns"
  project_name         = "myapp-dev"
  location             = "East US"
  dns_zone_name        = "dev.myapp.com"
  resource_group_name  = module.networking.resource_group_name
  ingress_public_ip_id = azurerm_public_ip.dev_ingress.id

  # Development-specific subdomains
  subdomain_records = [
    { name = "api",     target = "dev.myapp.com" },
    { name = "staging", target = "dev.myapp.com" },
    { name = "test",    target = "dev.myapp.com" }
  ]

  # Shorter TTL for development (faster changes)
  root_ttl      = 60
  subdomain_ttl = 60

  tags = merge(var.tags, { Environment = "Development" })
}
```

## DNS Setup Process

### 1. Domain Registration
- Purchase domain from registrar (GoDaddy, Namecheap, etc.)
- Keep registrar account credentials secure

### 2. Azure DNS Configuration
```bash
# Deploy this module with Terraform
terraform apply

# Note the nameservers from output
terraform output dns_nameservers
```

### 3. Update Nameservers at Registrar
```
# Update your domain registrar to use Azure nameservers:
ns1-01.azure-dns.com
ns2-01.azure-dns.net
ns3-01.azure-dns.org
ns4-01.azure-dns.info
```

### 4. Verify DNS Propagation
```bash
# Check DNS propagation (may take 24-48 hours)
dig buildandship.space
nslookup buildandship.space

# Online tools
https://dnschecker.org/
https://whatsmydns.net/
```

## Monitoring & Troubleshooting

### DNS Verification Commands
```bash
# Check A record
dig A buildandship.space

# Check all records
dig ANY buildandship.space

# Check specific record type
dig MX buildandship.space
dig TXT buildandship.space

# Check with specific nameserver
dig @ns1-01.azure-dns.com buildandship.space
```

### Common Issues
- **Nameserver propagation delay**: 24-48 hours for global propagation
- **TTL caching**: Old records cached until TTL expires
- **Missing records**: Verify record configuration and deployment
- **Certificate validation failures**: Check CAA records and DNS validation

### DNS Health Monitoring
- **Azure Monitor**: Built-in DNS query monitoring
- **External monitoring**: Use services like Pingdom, UptimeRobot
- **DNS propagation**: Monitor global DNS propagation status

<!-- BEGIN_TF_DOCS -->
## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | n/a |

## Resources

| Name | Type |
|------|------|
| [azurerm_dns_a_record.root](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/dns_a_record) | resource |
| [azurerm_dns_zone.dns](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/dns_zone) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_dns_zone_name"></a> [dns\_zone\_name](#input\_dns\_zone\_name) | The DNS zone name (your domain) | `string` | n/a | yes |
| <a name="input_ingress_public_ip_id"></a> [ingress\_public\_ip\_id](#input\_ingress\_public\_ip\_id) | Resource ID of the static public IP (passed from main.tf) | `string` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | Azure region | `string` | n/a | yes |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | Project name for resource naming | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Name of the resource group | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_dns_zone_id"></a> [dns\_zone\_id](#output\_dns\_zone\_id) | DNS Zone resource ID |
| <a name="output_dns_zone_name"></a> [dns\_zone\_name](#output\_dns\_zone\_name) | DNS Zone name |
| <a name="output_name_servers"></a> [name\_servers](#output\_name\_servers) | Name servers to configure at your domain registrar |
| <a name="output_root_domain_fqdn"></a> [root\_domain\_fqdn](#output\_root\_domain\_fqdn) | FQDN of the root domain A record |
<!-- END_TF_DOCS -->