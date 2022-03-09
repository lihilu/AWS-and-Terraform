provider "aws" {
  profile = "default"
  region  = "eu-west-2"

  default_tags {
    tags = {
      Owner = var.owner_tag
      Purpose = var.purpose_tag
    }
  }
}
