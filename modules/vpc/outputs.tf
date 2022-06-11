output "vpc" {
  description = "VPC object"
  value       = aws_vpc.this
}

output "private_subnets" {
  description = "Private subnets objects"
  value       = aws_subnet.private_subnets[*]
}

output "private_subnets_rtb" {
  description = "Private subnets route tables objects"
  value       = aws_route_table.private_subnets[*]
}