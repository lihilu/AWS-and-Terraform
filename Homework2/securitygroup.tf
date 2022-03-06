####WEB - Security Group

resource "aws_security_group" "nginx_instances_access" {
  vpc_id = aws_vpc.vpc.id
  name   = "nginx-access"

  tags = {
    "Name" = "${var.environment} - nginx-access-${aws_vpc.vpc.id}"
  }
}

resource "aws_security_group_rule" "nginx_http_acess" {
  description       = "${var.environment} - allow http access from anywhere"
  from_port         = var.webport
  protocol          = "tcp"
  security_group_id = aws_security_group.nginx_instances_access.id
  to_port           = var.webport
  type              = "ingress"
  cidr_blocks       = [var.cidr_blocks]
}

resource "aws_security_group_rule" "nginx_ssh_acess" {
  description       = "${var.environment} - allow ssh access from anywhere"
  from_port         = var.sshport
  protocol          = "tcp"
  security_group_id = aws_security_group.nginx_instances_access.id
  to_port           = var.sshport
  type              = "ingress"
  cidr_blocks       = [var.cidr_blocks]
}

resource "aws_security_group_rule" "nginx_outbound_anywhere" {
  description       = "${var.environment} - allow outbound traffic to anywhere"
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
  name   = "${var.environment} - DB-access"

  tags = {
    "Name" = "${var.environment} - DB-access-${aws_vpc.vpc.id}"
  }
}

resource "aws_security_group_rule" "DB_ssh_acess" {
  description       = "${var.environment} - allow ssh access from anywhere"
  from_port         = var.sshport
  protocol          = "tcp"
  security_group_id = aws_security_group.DB_instnaces_access.id
  to_port           = var.sshport
  type              = "ingress"
  cidr_blocks       = [var.cidr_blocks]
}

resource "aws_security_group_rule" "DB_outbound_anywhere" {
  description       = "${var.environment} - allow outbound traffic to anywhere"
  from_port         = 0
  protocol          = "-1"
  security_group_id = aws_security_group.DB_instnaces_access.id
  to_port           = 0
  type              = "egress"
  cidr_blocks       = [var.cidr_blocks]
}

