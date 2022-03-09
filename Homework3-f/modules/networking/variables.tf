variable "namespace" {
  type = string
}

variable "vpc_cidr_block" {
  default = "10.0.0.0/16"
}

variable "purpose_tag" {
  default = "Whiskey"
  type    = string
}

variable "private_subnet" {
  type    = list(string)
  default = ["10.0.2.0/24", "10.0.3.0/24"]
}

variable "public_subnet" {
  type    = list(string)
  default = ["10.0.4.0/24", "10.0.5.0/24"]
}

variable "route_tables_names" {
  type    = list(string)
  default = ["public", "private-a", "private-b"]
}

variable "cidr_blocks" {
  default = "0.0.0.0/0"
  
}

variable "webport" {
  description = "allow http access"
  default = "80"  
}

variable "sshport" {
  description = "allow ssh access"
  default = "22"  
}


#variable "tg_config" {
#  type = map(string)
#}