variable "sys" {
  type        = string
  default     = "tanavel"
  description = "System name used for resource name etc..."
}

variable "backend_s3_bucket_name" {
  type        = string
  description = "S3 bucket name used for terraform backend"
}

variable "domain_name" {
  type        = string
  default     = "tanavel.net"
  description = "Domain name"
}

variable "hosted_zone_name" {
  type        = string
  default     = "tanavel.net"
  description = "Hosted zone name"
}
