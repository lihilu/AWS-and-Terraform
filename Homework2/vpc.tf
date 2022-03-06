resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr_block

  tags = {
    "Name" = "${var.environment} - VPC - ${var.purpose_tag}"
  }
}

# SUBNETS
resource "aws_subnet" "public" {
  map_public_ip_on_launch = "true"
  count                   = length(var.public_subnet)
  cidr_block              = var.public_subnet[count.index]
  vpc_id                  = aws_vpc.vpc.id
  availability_zone       = data.aws_availability_zones.available.names[count.index]

  tags = {
    "Name" = "${var.environment} - Public_subnet_${regex(".$", data.aws_availability_zones.available.names[count.index])}_${aws_vpc.vpc.id}"
  }
}

resource "aws_subnet" "private" {
  count                   = length(var.private_subnet)
  cidr_block              = var.private_subnet[count.index]
  vpc_id                  = aws_vpc.vpc.id
  map_public_ip_on_launch = "false"
  availability_zone       = data.aws_availability_zones.available.names[count.index]

  tags = {
    "Name" = "${var.environment} - Private_subnet_${regex(".$", data.aws_availability_zones.available.names[count.index])}_${aws_vpc.vpc.id}"
  }
}

# IGW
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    "Name" = "${var.environment} - IGW_${aws_vpc.vpc.id}"
  }
}

# EIPs (for nats)
resource "aws_eip" "eip" {
  count = length(var.public_subnet)

  tags = {
    "Name" = "${var.environment} - NAT_elastic_ip_${regex(".$", data.aws_availability_zones.available.names[count.index])}_${aws_vpc.vpc.id}"
  }
}

# NATs
resource "aws_nat_gateway" "nat" {
  count         = length(var.public_subnet)
  allocation_id = aws_eip.eip.*.id[count.index]
  subnet_id     = aws_subnet.public.*.id[count.index]

  tags = {
    "Name" = "${var.environment} - NAT_${regex(".$", data.aws_availability_zones.available.names[count.index])}_${aws_vpc.vpc.id}"
  }
}

# ROUTING #
resource "aws_route_table" "route_tables" {
  count  = length(var.route_tables_names)
  vpc_id = aws_vpc.vpc.id

  tags = {
    "Name" = "${var.environment} - ${var.route_tables_names[count.index]}_RTB_${aws_vpc.vpc.id}"
  }
}

resource "aws_route_table_association" "public" {
  count          = length(var.public_subnet)
  subnet_id      = aws_subnet.public.*.id[count.index]
  route_table_id = aws_route_table.route_tables[0].id
}

resource "aws_route_table_association" "private" {
  count          = length(var.private_subnet)
  subnet_id      = aws_subnet.private.*.id[count.index]
  route_table_id = aws_route_table.route_tables[count.index + 1].id
}

resource "aws_route" "public" {
  route_table_id         = aws_route_table.route_tables[0].id
  destination_cidr_block = var.cidr_blocks
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route" "private" {
  count                  = length(var.private_subnet)
  route_table_id         = aws_route_table.route_tables.*.id[count.index + 1]
  destination_cidr_block = var.cidr_blocks
  nat_gateway_id         = aws_nat_gateway.nat.*.id[count.index]
}