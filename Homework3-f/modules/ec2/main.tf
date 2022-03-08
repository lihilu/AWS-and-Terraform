

// Create aws_ami filter to pick up the ami available in your region
data "aws_ami" "ubuntu-18" {
  most_recent = true
  owners      = [var.ubuntu_account_number]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }
}
variable "ubuntu_account_number" {
  default = "099720109477"
}

// Configure the EC2 instance in a public subnet
resource "aws_instance" "ec2_web" {
  ami                         = var.ec2_ami
  associate_public_ip_address = true
  instance_type               = var.instance_type
  key_name                    = var.key_name
  subnet_id                   = var.subnet_public_id[0]
  vpc_security_group_ids      = [var.sg_pub_id]

  tags = {
    #var.tags
    "Name" = "${var.env_name} - WEB"
  }
  
    # root disk
  root_block_device {
    volume_size           = "30"
    volume_type           = var.volume_type
    encrypted             = false
  }
  #data disk
    ebs_block_device {
    device_name           = "/dev/xvda"
    volume_size           = var.volume_size
    volume_type           = var.volume_type
    encrypted             = true
  }
}

// Configure the EC2 instance in a private subnet
resource "aws_instance" "ec2_db" {
  ami                         = var.ec2_ami
  associate_public_ip_address = false
  instance_type               = var.instance_type
  key_name                    = var.key_name
  subnet_id                   = var.subnet_private_id[1]
  vpc_security_group_ids      = [var.sg_priv_id]
  tags = {
    "Name" = "${var.env_name} - DB"
  }
  
    # root disk
  root_block_device {
    volume_size           = "30"
    volume_type           = var.volume_type
    encrypted             = false
  }
  #data disk
    ebs_block_device {
    device_name           = "/dev/xvda"
    volume_size           = var.volume_size
    volume_type           = var.volume_type
    encrypted             = true
  }

}