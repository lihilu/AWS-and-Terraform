terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }

  required_version = ">= 0.14.9"
}

provider "aws" {
  profile = "default"
  region  = "us-west-2"
}


  resource "tls_private_key" "admin1" {
    algorithm = "RSA"
    rsa_bits  = 2048
  }
  resource "aws_key_pair" "admin1" {
    key_name   = "admin1"
    public_key = tls_private_key.admin1.public_key_openssh
  }
  # Save generated key pair locally
    resource "local_file" "server_key" {
    sensitive_content  = tls_private_key.admin1.private_key_pem
    filename           = "admin1.pem"
  }
    resource "aws_security_group" "ssh-http"{
     name = "ssh-http"
    description = "allowing ssh and http traffic"
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
     ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
  }

resource "aws_instance" "ec2" {
  ami           = var.ec2_ami
  instance_type = var.instance_type
  count=var.ins_count
  key_name ="${aws_key_pair.admin1.key_name}"
  security_groups = ["${aws_security_group.ssh-http.name}"]
  tags = {
    Name = "wiskey_web${count.index}"
    owner= "LihiReisman"
    Purpose="Grendpa's Wiskey"

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
user_data = <<EOF
#!bin/bash
sudo yum install nginx -y
sudo systemctl start nginx
echo "Welcome to Grandpa's Whiskey" | sudo tee /usr/share/nginx/html/index.html
EOF

} 


