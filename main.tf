# Create Aviatrix Transit
module "transit" {
  source  = "terraform-aviatrix-modules/mc-transit/aviatrix"
  version = "2.1.1"

  cloud   = "aws"
  account = var.vpc_data.transit.account
  region  = var.aws_region
  name    = "${var.name_suffix}-${var.vpc_data.transit.name}"
  cidr    = var.vpc_data.transit.cidr
  ha_gw   = var.ha_gw
}

# Create Aviatrix Spoke
module "spoke" {
  source  = "terraform-aviatrix-modules/mc-spoke/aviatrix"
  version = "1.2.0"

  cloud      = "aws"
  account    = var.vpc_data.spoke.account
  region     = var.aws_region
  name       = "${var.name_suffix}-${var.vpc_data.spoke.name}"
  cidr       = var.vpc_data.spoke.cidr
  ha_gw      = var.ha_gw
  transit_gw = module.transit.transit_gateway.gw_name
}

# Create AWS Peering Spoke
module "peering_spoke" {
  source  = "terraform-aviatrix-modules/mc-spoke/aviatrix"
  version = "1.2.0"

  cloud      = "aws"
  account    = var.vpc_data.peering_spoke.account
  region     = var.aws_region
  name       = "${var.name_suffix}-${var.vpc_data.peering_spoke.name}"
  cidr       = var.vpc_data.peering_spoke.cidr
  ha_gw      = var.ha_gw
  transit_gw = module.transit.transit_gateway.gw_name

  #included_advertised_spoke_routes = "${var.vpc_data.tgw_spoke.cidr},${var.vpc_data.peering_spoke.cidr}"
}

# Create SSM Instance Profile
module "ssm_instance_profile" {
  source  = "bayupw/ssm-instance-profile/aws"
  version = "1.1.0"

  partition                 = "china"
  ssm_instance_role_name    = "bwibowo-ssm-role"
  ssm_instance_profile_name = "bwibowo-ssm-instance-profile"
}

# Create SSM VPCE in Aviatrix Spoke
module "spoke_ssm_vpce" {
  source  = "bayupw/ssm-vpc-endpoint/aws"
  version = "1.0.1"

  vpc_id         = module.spoke.vpc.vpc_id
  vpc_subnet_ids = module.spoke.vpc.private_subnets[*].subnet_id

  depends_on = [module.spoke]
}

# Create EC2 instance in Aviatrix Spoke
module "spoke_ec2" {
  source  = "bayupw/amazon-linux-2/aws"
  version = "1.0.0"

  vpc_id               = module.spoke.vpc.vpc_id
  subnet_id            = module.spoke.vpc.private_subnets[0].subnet_id
  iam_instance_profile = module.ssm_instance_profile.aws_iam_instance_profile
  instance_type        = "t3.micro"
  instance_hostname    = "${var.name_suffix}-ec2-avx-spoke"
  random_password      = false
  instance_password    = "Aviatrix123#"

  depends_on = [module.spoke, module.spoke_ssm_vpce]
}

# Create SSM VPCE in Aviatrix Spoke
module "peering_spoke_ssm_vpce" {
  source  = "bayupw/ssm-vpc-endpoint/aws"
  version = "1.0.1"

  vpc_id         = module.peering_spoke.vpc.vpc_id
  vpc_subnet_ids = module.peering_spoke.vpc.private_subnets[*].subnet_id

  depends_on = [module.peering_spoke]
}

# Create EC2 instance in Aviatrix Spoke
module "peering_spoke_ec2" {
  source  = "bayupw/amazon-linux-2/aws"
  version = "1.0.0"

  vpc_id               = module.peering_spoke.vpc.vpc_id
  subnet_id            = module.peering_spoke.vpc.private_subnets[0].subnet_id
  iam_instance_profile = module.ssm_instance_profile.aws_iam_instance_profile
  instance_type        = "t3.micro"
  instance_hostname    = "${var.name_suffix}-ec2-avx-peering-spoke"
  random_password      = false
  instance_password    = "Aviatrix123#"

  depends_on = [module.peering_spoke, module.spoke_ssm_vpce]
}

# Retrieve aws_peering_spoke public_subnets rtb
data "aws_route_table" "peering_spoke_public_rtbs" {
  count = 2

  subnet_id  = module.peering_spoke.vpc.public_subnets[count.index].subnet_id
  depends_on = [module.peering_spoke]
}

# Create route to existing AWS VPC via TGW
resource "aws_route" "peering_spoke_to_tgw" {
  count = 2

  route_table_id         = data.aws_route_table.peering_spoke_public_rtbs[count.index].id
  destination_cidr_block = var.vpc_data.tgw_spoke.cidr
  transit_gateway_id     = module.tgw.ec2_transit_gateway_id

  depends_on = [module.peering_spoke, module.tgw]
}