variable "sys" {
  type        = string
  default     = "tanavel"
  description = "System name used for resource name etc..."
}

variable "db_username" {
  type        = string
  default     = "root"
  description = "DB default user name"
}

variable "db_password" {
  type        = string
  default     = "password"
  description = "DB default password"
}
