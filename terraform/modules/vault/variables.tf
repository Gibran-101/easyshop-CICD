# variable "vault_name" {}
# variable "location" {}
# variable "resource_group_name" {}
# variable "tenant_id" {}
# variable "admin_object_id" {}

variable "location" {}

variable "resource_group_name" {}

variable "admin_object_id" {}

variable "secret_values" {
  type = map(string)
}
variable "key_vault_name" {}

variable "tenant_id" {
  description = "This is the ID for tenant"
  type = string
}

