data "aws_partition" "current" {}

################################################################################
# Existing Spoke VPC for TGW Module
################################################################################
module "tgw_spoke" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 3.0"

  name = "${var.name_suffix}-existing-spoke"
  cidr = var.vpc_data.tgw_spoke.cidr

  azs             = ["${var.aws_region}a", "${var.aws_region}b"]
  private_subnets = [cidrsubnet(var.vpc_data.tgw_spoke.cidr, 1, 0), cidrsubnet(var.vpc_data.tgw_spoke.cidr, 1, 1)]

  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = local.tags
}

################################################################################
# Transit Gateway Module
################################################################################
module "tgw" {
  source  = "terraform-aws-modules/transit-gateway/aws"
  version = "2.8.0"

  name            = "${var.name_suffix}-tgw"
  amazon_side_asn = 64532
  share_tgw       = false

  vpc_attachments = {
    tgw_spoke = {
      vpc_id       = module.tgw_spoke.vpc_id
      subnet_ids   = module.tgw_spoke.private_subnets
      dns_support  = true
      ipv6_support = false

      transit_gateway_default_route_table_association = false
      transit_gateway_default_route_table_propagation = false

      tgw_routes = [
        {
          destination_cidr_block = var.vpc_data.tgw_spoke.cidr
        },
      ]
    },
    peering_spoke = {
      vpc_id       = module.peering_spoke.vpc.vpc_id
      subnet_ids   = module.peering_spoke.vpc.private_subnets[*].subnet_id
      dns_support  = true
      ipv6_support = false

      transit_gateway_default_route_table_association = false
      transit_gateway_default_route_table_propagation = false

      tgw_routes = [
        {
          destination_cidr_block = var.vpc_data.peering_spoke.cidr
        },
        {
          destination_cidr_block = var.vpc_data.spoke.cidr
        },
      ]
    },
  }

  tags = local.tags

  depends_on = [
    module.tgw_spoke,
    module.peering_spoke,
    module.spoke
  ]
}

# Create route to Aviatrix Spoke via TGW
resource "aws_route" "tgw_spoke_to_tgw" {
  count = length(module.tgw_spoke.private_route_table_ids)

  route_table_id         = module.tgw_spoke.private_route_table_ids[count.index]
  destination_cidr_block = var.vpc_data.spoke.cidr
  transit_gateway_id     = module.tgw.ec2_transit_gateway_id

  depends_on = [module.tgw]
}