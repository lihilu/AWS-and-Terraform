# INSTANCES - WEB
resource "aws_instance" "nginx" {
  count                       = var.nginx_instances_count
  ami                         = data.aws_ami.ubuntu-18.id
  instance_type               = var.instance_type
  key_name                    = var.key_name
  iam_instance_profile        = "${aws_iam_instance_profile.admin.name}"
  subnet_id                   = aws_subnet.public.*.id[count.index]
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.nginx_instances_access.id]
  user_data                   = local.userdata

  root_block_device {
    encrypted   = false
    volume_type = var.volumes_type
    volume_size = var.nginx_root_disk_size
  }

  ebs_block_device {
    encrypted   = true
    device_name = var.nginx_encrypted_disk_device_name
    volume_type = var.volumes_type
    volume_size = var.nginx_encrypted_disk_size
  }

  tags = {
    "Name" = "${var.environment} - nginx-web-${regex(".$", data.aws_availability_zones.available.names[count.index])}"
  }
}


# INSTANCES - DB

resource "aws_instance" "DB_instances" {
  count                       = var.DB_instances_count
  ami                         = data.aws_ami.ubuntu-18.id
  instance_type               = var.instance_type
  key_name                    = var.key_name
  subnet_id                   = aws_subnet.private.*.id[count.index]
  associate_public_ip_address = false
  vpc_security_group_ids      = [aws_security_group.DB_instnaces_access.id]

  tags = {
    "Name" = "${var.environment} - DB-${regex(".$", data.aws_availability_zones.available.names[count.index])}"
  }
}

