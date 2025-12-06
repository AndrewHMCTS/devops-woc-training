variable "location" {
  type    = string
  default = "uksouth"
}

variable "resource_group_name" {
  type    = string
  default = "rg-filevault"
}

variable "acr_name" {
  type    = string
  default = "filevaultacr"
}

variable "aks_name" {
  type    = string
  default = "filevault-aks"
}

variable "env" {
  description = "Environment name (sbox, stg, prod)"
  type        = string
}

variable "subscription_id" {
  description = "Azure Subscription ID"
  type        = string
}

variable "client_id" {
  description = "Azure Client ID"
  type        = string
}