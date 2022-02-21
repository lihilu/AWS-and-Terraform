variable "ec2_ami" {
    default = "ami-0b28dfc7adc325ef4"
  
}

variable "instance_type" {
    default = "t3.micro"
  
}


variable "ins_count" {
    type = number
    default = "2"
  
}

variable "name_prefixes" {
  default = "web"
}

variable "volume_size" {
    type = number
    default = "10"
  
}

variable "volume_type" {
    default = "gp2"
  
}

 variable "ingressrules" {
    type    = list(number)
    default = [80, 443, 22]
  }