// TODO break public and private into separate AZs
data "aws_availability_zones" "available" {}


resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr_block

  tags = {
    "Name" = "VPC - ${var.purpose_tag}"
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
    "Name" = "Public_subnet_${regex(".$", data.aws_availability_zones.available.names[count.index])}"
  }
}

resource "aws_subnet" "private" {
  count                   = length(var.private_subnet)
  cidr_block              = var.private_subnet[count.index]
  vpc_id                  = aws_vpc.vpc.id
  map_public_ip_on_launch = "false"
  availability_zone       = data.aws_availability_zones.available.names[count.index]

  tags = {
    "Name" = "Private_subnet_${regex(".$", data.aws_availability_zones.available.names[count.index])}"
  }
}

# IGW
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    "Name" = "IGW"
  }
}

# EIPs (for nats)
resource "aws_eip" "eip" {
  count = length(var.public_subnet)

  tags = {
    "Name" = "NAT_elastic_ip_${regex(".$", data.aws_availability_zones.available.names[count.index])}"
  }
}

# NATs
resource "aws_nat_gateway" "nat" {
  count         = length(var.public_subnet)
  allocation_id = aws_eip.eip.*.id[count.index]
  subnet_id     = aws_subnet.public.*.id[count.index]

  tags = {
    "Name" = "NAT_${regex(".$", data.aws_availability_zones.available.names[count.index])}"
  }
}

# ROUTING #
resource "aws_route_table" "route_tables" {
  count  = length(var.route_tables_names)
  vpc_id = aws_vpc.vpc.id

  tags = {
    "Name" = "${var.route_tables_names[count.index]}_RTB"
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

resource "aws_security_group" "nginx_instances_access" {
  vpc_id = aws_vpc.vpc.id
  name   = "nginx-access"

  tags = {
    "Name" = "web-access-"
  }
}

resource "aws_security_group_rule" "nginx_http_acess" {
  description       = "allow http access from anywhere"
  from_port         = var.webport
  protocol          = "tcp"
  security_group_id = aws_security_group.nginx_instances_access.id
  to_port           = var.webport
  type              = "ingress"
  cidr_blocks       = [var.cidr_blocks]
}

resource "aws_security_group_rule" "nginx_ssh_acess" {
  description       = "allow ssh access from anywhere"
  from_port         = var.sshport
  protocol          = "tcp"
  security_group_id = aws_security_group.nginx_instances_access.id
  to_port           = var.sshport
  type              = "ingress"
  cidr_blocks       = [var.cidr_blocks]
}

resource "aws_security_group_rule" "nginx_outbound_anywhere" {
  description       = "allow outbound traffic to anywhere"
  from_port         = 0
  protocol          = "-1"
  security_group_id = aws_security_group.nginx_instances_access.id
  to_port           = 0
  type              = "egress"
  cidr_blocks       = [var.cidr_blocks]
}


##########################################


####DB - Security Group
resource "aws_security_group" "DB_instnaces_access" {
  vpc_id = aws_vpc.vpc.id
  name   = " DB-access"

  tags = {
    "Name" = " DB-access"
  }
}

resource "aws_security_group_rule" "DB_ssh_acess" {
  description       = "allow ssh access from anywhere"
  from_port         = var.sshport
  protocol          = "tcp"
  security_group_id = aws_security_group.DB_instnaces_access.id
  to_port           = var.sshport
  type              = "ingress"
  cidr_blocks       = [var.cidr_blocks]
}

resource "aws_security_group_rule" "DB_outbound_anywhere" {
  description       = "allow outbound traffic to anywhere"
  from_port         = 0
  protocol          = "-1"
  security_group_id = aws_security_group.DB_instnaces_access.id
  to_port           = 0
  type              = "egress"
  cidr_blocks       = [var.cidr_blocks]
}

###################LB

resource "aws_lb" "web-nginx" {
  name                       = "nginx-alb-${aws_vpc.vpc.id}"
  internal                   = false
  load_balancer_type         = "application"
  subnets                    = var.public_subnet
  security_groups            = [aws_security_group.nginx_instances_access.id]


  tags = {
    "Name" = "nginx-alb-${aws_vpc.vpc.id}"
  }
}

resource "aws_lb_listener" "web-nginx" {
  load_balancer_arn = aws_lb.web-nginx.arn
  port              = var.webport
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web-nginx.arn
  }
}


resource "aws_lb_target_group" "web-nginx" {
  name     = "nginx-target-group"
  port     = var.webport
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc.id

  health_check {
    enabled = true
    path    = "/"
  }
  stickiness {    
    type            = "lb_cookie"    
    cookie_duration = 60   
    enabled         = "true"  
  } 

  tags = {
    "Name" = "nginx-target-group-${aws_vpc.vpc.id}"
  }
}

#resource "aws_lb_target_group_attachment" "web_server" {
#  target_group_arn = aws_lb_target_group.web-nginx.id
#  port             = var.webport
#}
