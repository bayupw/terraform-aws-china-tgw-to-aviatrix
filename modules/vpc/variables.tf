variable "vpc_name" {
  description = "VPC name"
  type        = string
}

variable "cidr" {
  description = "The CIDR block for the VPC"
  type        = string
}

variable "private_subnets" {
  description = "A list of private subnets inside the VPC"
  type        = list(string)
  default     = []
}

variable "private_subnets_suffix" {
  description = "Suffix to append to private subnets name"
  type        = string
  default     = "private"
}

variable "enable_dns_support" {
  description = "DNS support"
  type        = bool
  default     = false
}

variable "enable_dns_hostnames" {
  description = "DNS hostname"
  type        = bool
  default     = false
}

variable "azs" {
  description = "A list of availability zones names or ids in the region"
  type        = list(string)
  default     = []
}