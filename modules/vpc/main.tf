resource "aws_vpc" "this" {
  cidr_block           = var.cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    "Name" = var.vpc_name
  }
}

resource "aws_subnet" "private_subnets" {
  count = length(var.private_subnets)

  vpc_id                  = aws_vpc.this.id
  cidr_block              = element(concat(var.private_subnets, [""]), count.index)
  availability_zone       = length(regexall("^[a-z]{2}-", element(var.azs, count.index))) > 0 ? element(var.azs, count.index) : null
  availability_zone_id    = length(regexall("^[a-z]{2}-", element(var.azs, count.index))) == 0 ? element(var.azs, count.index) : null
  map_public_ip_on_launch = true

  tags = {
    "Name" = format(
      "${var.vpc_name}-${var.private_subnets_suffix}-%s",
    element(var.azs, count.index), )
  }

  depends_on = [aws_vpc.this]
}

resource "aws_route_table" "private_subnets" {
  count = length(var.private_subnets)

  vpc_id = aws_vpc.this.id

  tags = {
    "Name" = "${var.vpc_name}-${var.private_subnets_suffix}-${element(var.azs, count.index)}"
  }

  depends_on = [aws_vpc.this]
}

resource "aws_route_table_association" "private_subnets" {
  count = length(var.private_subnets)

  subnet_id      = element(aws_subnet.private_subnets[*].id, count.index)
  route_table_id = aws_route_table.private_subnets[count.index].id
}