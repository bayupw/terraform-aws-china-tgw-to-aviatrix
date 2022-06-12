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

variable "aws_cli_profile" {
  description = "AWS CLI named profile"
  type        = string
  default     = "default"
}

variable "name_suffix" {
  description = "Name suffix for tags"
  type        = string
  default     = "bwibowo"
}

variable "vpc_data" {
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