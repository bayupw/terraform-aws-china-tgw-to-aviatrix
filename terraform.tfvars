aws_region          = "cn-north-1"
aws_account         = "aws-china-account"
name_suffix         = "bwibowo"
existing_spoke_cidr = "10.1.0.0/24"
ha_gw               = true

aviatrix_data = {
  spoke = {
    cloud   = 1024
    account = "aws-china-account"
    region  = "cn-north-1"
    name    = "spoke1"
    cidr    = "10.2.0.0/24"
    gw_size = "t3.micro"
  }
  transit = {
    cloud   = 1024
    account = "aws-china-account"
    region  = "cn-north-1"
    name    = "transit"
    cidr    = "10.2.254.0/23"
    gw_size = "t3.micro"
    asn     = "65011"
  }
  peering_spoke = {
    cloud   = 1024
    account = "aws-china-account"
    region  = "cn-north-1"
    name    = "peering-spoke"
    cidr    = "10.2.253.0/24"
    gw_size = "t3.micro"
  }
}