################################################################################
# SSM, SSM VPC Endpoint and EC2 Instances
################################################################################

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
  instance_hostname    = "${var.name_suffix}-ec2-avx-spoke-a"
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
  instance_hostname    = "${var.name_suffix}-ec2-avx-peering-spoke-a"
  random_password      = false
  instance_password    = "Aviatrix123#"

  depends_on = [module.peering_spoke, module.spoke_ssm_vpce]
}

# Create SSM VPC Endpoint
module "tgw_spoke_ssm_vpce" {
  source  = "bayupw/ssm-vpc-endpoint/aws"
  version = "1.0.1"

  vpc_id         = module.tgw_spoke.vpc_id
  vpc_subnet_ids = module.tgw_spoke.private_subnets[*]

  depends_on = [module.tgw_spoke]
}

# Create EC2 instance in Existing spoke
module "tgw_spoke_ec2" {
  source  = "bayupw/amazon-linux-2/aws"
  version = "1.0.0"

  vpc_id               = module.tgw_spoke.vpc_id
  subnet_id            = module.tgw_spoke.private_subnets[0]
  iam_instance_profile = module.ssm_instance_profile.aws_iam_instance_profile
  instance_type        = "t3.micro"
  instance_hostname    = "${var.name_suffix}-ec2-tgw-spoke-a"
  random_password      = false
  instance_password    = "Aviatrix123#"

  depends_on = [module.tgw_spoke, module.tgw_spoke_ssm_vpce]
}