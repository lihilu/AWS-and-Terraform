variable "env_name" {
  type = string
}

variable "ec2_ami" {
    default = "ami-0ec6693177fb5d713"
  
}
variable "volume_size" {
    type = number
    default = "10"
  
}

variable "volume_type" {
    default = "gp2"
  
}
variable "aws_vpc" {
  type = any
}

variable "key_name" {
  type = string
}

variable "sg_pub_id" {
  type = any
}

variable "sg_priv_id" {
  type = any
}

variable "instance_type" {
  description = "The type of the ec2, for example - t2.medium"
  type        = string
  default     = "t2.micro"
}

variable "subnet_public_id"{}

variable "subnet_private_id" {}