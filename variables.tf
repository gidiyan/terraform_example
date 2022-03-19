variable "rg_name" {
  type        = string
  description = "Name of resource group"
  default     = "gidiyan-rg"
}

variable "user" {
  type        = string
  description = "Username"
  default     = "adminUsername"
}

variable "password" {
  type        = string
  description = "Password"
  default     = "Password1234!"
}

variable "vm_names" {
  type        = list(string)
  description = "Virtual machine names list"
  default     = ["vm1", "vm2"]
}

variable "location" {
  type        = string
  description = "Location"
  default     = "West Europe"
}

variable "object_id" {
  type        = string
  description = "Account ID"
  default     = "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX"
}
