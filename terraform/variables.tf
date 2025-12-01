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