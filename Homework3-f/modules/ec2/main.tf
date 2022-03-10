

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
  count                       = "2"
  associate_public_ip_address = true
  instance_type               = var.instance_type
  key_name                    = var.key_name
  iam_instance_profile        = aws_iam_instance_profile.admin.name
  subnet_id                   = var.subnet_public_id[count.index]
  vpc_security_group_ids      = [var.sg_pub_id]
  user_data                   = file("${path.module}${var.user_data_web}")

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
  count = "2"
  associate_public_ip_address = false
  instance_type               = var.instance_type
  key_name                    = var.key_name
  subnet_id                   = var.subnet_private_id[count.index]
  vpc_security_group_ids      = [var.sg_priv_id]
  tags = {
    "Name" = "${var.env_name} - DB - ${regex(".$", data.aws_availability_zones.available.names[count.index])}"
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


###################LB

resource "aws_lb" "web-nginx" {
  name               = "nginx-alb-${var.aws_vpc.id}"
  internal           = false
  load_balancer_type = "application"
  security_groups    = var.lb_sg_array
  subnets            = var.subnet_public_id

  enable_deletion_protection = false

  tags = {
    Environment = "nginx-alb-${var.aws_vpc.id}"
  }
}

resource "aws_lb_listener" "web-nginx" {
  load_balancer_arn = aws_lb.web-nginx.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web-nginx.arn
  }
}


resource "aws_lb_target_group" "web-nginx" {
  name     = "nginx-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.aws_vpc.id

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
    "Name" = "nginx-target-group-${var.aws_vpc.id}"
  }
}

resource "aws_lb_target_group_attachment" "web_server" {
  count = length(aws_instance.ec2_web)
  target_group_arn = aws_lb_target_group.web-nginx.id
  target_id        = aws_instance.ec2_web.*.id[count.index]
  port             = 80
}
