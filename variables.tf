# cn-north-1 = Beijing | cn-northwest-1 = Ningxia
variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "cn-north-1"
}

variable "aws_account" {
  description = "AWS access account in Aviatrix"
  type        = string
  default     = "aws-china-account"
}

variable "name_suffix" {
  description = "Name suffix for tags"
  type        = string
  default     = "bwibowo"
}

variable "existing_spoke_cidr" {
  description = "CIDR for existing spoke attached to AWS TGW"
  type        = string
  default     = "10.1.0.0/24"
}

variable "aviatrix_data" {
  description = "Maps of Aviatrix transit and spoke data (VPC and gateways)"
  type        = map(any)
}

variable "ha_gw" {
  description = "Enable Aviatrix HA Gateway"
  type        = bool
  default     = true
}

locals {
  account = var.aws_account
  region  = var.aws_region

  tags = {
    UserID = var.name_suffix
  }
}