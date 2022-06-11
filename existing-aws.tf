data "aws_partition" "current" {}

################################################################################
# Existing Spoke VPC for TGW Module
################################################################################
module "existing_spoke_vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 3.0"

  name = "${var.name_suffix}-existing-spoke"
  cidr = var.existing_spoke_cidr

  azs             = ["${var.aws_region}a"]
  private_subnets = [var.existing_spoke_cidr]

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
    existing_spoke_vpc = {
      vpc_id       = module.existing_spoke_vpc.vpc_id
      subnet_ids   = module.existing_spoke_vpc.private_subnets
      dns_support  = true
      ipv6_support = false

      transit_gateway_default_route_table_association = false
      transit_gateway_default_route_table_propagation = false

      tgw_routes = [
        {
          destination_cidr_block = var.existing_spoke_cidr
        },
      ]
    },
    aws_peering_spoke = {
      vpc_id       = module.peering_spoke.vpc.vpc_id
      subnet_ids   = module.peering_spoke.vpc.private_subnets[*].subnet_id
      dns_support  = true
      ipv6_support = false

      transit_gateway_default_route_table_association = false
      transit_gateway_default_route_table_propagation = false

      tgw_routes = [
        {
          destination_cidr_block = var.aviatrix_data.peering_spoke.cidr
        },
        {
          destination_cidr_block = var.aviatrix_data.spoke.cidr
        },
      ]
    },
  }

  tags = local.tags

  depends_on = [
    module.existing_spoke_vpc,
    module.peering_spoke, module.spoke
  ]
}

# Create route to Aviatrix Spoke via TGW
resource "aws_route" "existing_spoke_to_tgw" {
  count = length(module.existing_spoke_vpc.private_route_table_ids)

  route_table_id         = module.existing_spoke_vpc.private_route_table_ids[count.index] #data.aws_route_table.peering_spoke_public_rtbs[count.index].id
  destination_cidr_block = var.aviatrix_data.spoke.cidr
  transit_gateway_id     = module.tgw.ec2_transit_gateway_id

  depends_on = [module.tgw]
}

# Create SSM VPC Endpoint
module "ssm_vpce" {
  source  = "bayupw/ssm-vpc-endpoint/aws"
  version = "1.0.1"

  vpc_id         = module.existing_spoke_vpc.vpc_id
  vpc_subnet_ids = module.existing_spoke_vpc.private_subnets[*]

  depends_on = [module.existing_spoke_vpc]
}

# Create EC2 instance in Existing spoke
module "existing_spoke_ec2" {
  source  = "bayupw/amazon-linux-2/aws"
  version = "1.0.0"

  vpc_id               = module.existing_spoke_vpc.vpc_id
  subnet_id            = module.existing_spoke_vpc.private_subnets[0]
  iam_instance_profile = module.ssm_instance_profile.aws_iam_instance_profile
  instance_type        = "t3.micro"
  instance_hostname    = "${var.name_suffix}-ec2-existing-spoke"
  random_password      = false
  instance_password    = "Aviatrix123#"

  depends_on = [module.existing_spoke_vpc, module.ssm_vpce]
}