variable "location" {
  type    = string
  default = "uksouth"
}

variable "env" {
  description = "Environment name (sbox, stg, prod)"
  type        = string
}

variable "subscription_id" {
  description = "Azure Subscription ID"
  type        = string
  default     = ""
}

variable "client_id" {
  description = "Azure Client ID"
  type        = string
  default     = ""
}
