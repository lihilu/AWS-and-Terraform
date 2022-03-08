variable "aws_region" {
  default =  "eu-west-2"
  type    = string
}


variable "namespace" {
  description = "The project namespace to use for unique resource naming"
  default     = "prod"
  type        = string
}
