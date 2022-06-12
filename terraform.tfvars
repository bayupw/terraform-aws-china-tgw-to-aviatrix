aws_region      = "cn-north-1"
aws_account     = "aws-china-account"
aws_cli_profile = "aws-china-account"
name_suffix     = "bwibowo"
ha_gw           = true

vpc_data = {
  tgw_spoke = {
    name = "tgw-spoke"
    cidr = "10.1.0.0/24"
  }
  spoke = {
    cloud   = 1024
    account = "aws-china-account"
    name    = "spoke"
    cidr    = "10.2.0.0/24"
    gw_size = "t3.micro"
  }
  transit = {
    cloud   = 1024
    account = "aws-china-account"
    name    = "transit"
    cidr    = "10.2.200.0/23"
    gw_size = "t3.micro"
    asn     = "65011"
  }
  peering_spoke = {
    cloud   = 1024
    account = "aws-china-account"
    name    = "peering-spoke"
    cidr    = "10.2.100.0/24"
    gw_size = "t3.micro"
  }
}