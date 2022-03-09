
terraform {
  backend "s3" {
    bucket         = "s3bucketwiskey"
    key            = "s3/terraform.tfstate"
    region         = "eu-west-2"
    dynamodb_table = "dynmodb"
    encrypt        = true
  }
}