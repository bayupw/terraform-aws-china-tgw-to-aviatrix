################################################################################
# Aviatrix Environment: Transit, Spoke, Peering Spoke
################################################################################

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

# Retrieve peering_spoke public_subnets rtb
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