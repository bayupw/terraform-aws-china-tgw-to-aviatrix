output "ec2_ssm_tgw_spoke" {
  description = "Client Instance SSM command"
  value       = "aws ssm start-session --region ${var.aws_region} --target ${module.tgw_spoke_ec2.aws_instance.id} --profile aws-china-account"
}

output "ec2_private_ip_tgw_spoke" {
  description = "Client Private IP"
  value       = module.tgw_spoke_ec2.aws_instance.private_ip
}

output "ec2_ssm_aviatrix_spoke" {
  description = "Client Instance SSM command"
  value       = "aws ssm start-session --region ${var.aws_region} --target ${module.spoke_ec2.aws_instance.id} --profile aws-china-account"
}

output "ec2_private_ip_aviatrix_spoke" {
  description = "Client Private IP"
  value       = module.spoke_ec2.aws_instance.private_ip
}

output "ec2_ssm_aviatrix_peering_spoke" {
  description = "Client Instance SSM command"
  value       = "aws ssm start-session --region ${var.aws_region} --target ${module.peering_spoke_ec2.aws_instance.id} --profile aws-china-account"
}

output "ec2_private_ip_aviatrix_peering_spoke" {
  description = "Client Private IP"
  value       = module.peering_spoke_ec2.aws_instance.private_ip
}

output "spoke_gateway_customize_spoke_advertisement" {
  description = "Spoke gateway and network for custom spoke advertisement"
  value       = "${module.peering_spoke.spoke_gateway.gw_name}: ${var.vpc_data.tgw_spoke.cidr},${var.vpc_data.peering_spoke.cidr}"
}
