resource "aws_s3_bucket" "terraform_state" {
  bucket = "s3bucketwiskey"
}

resource "aws_s3_bucket" "loggingb" {
  bucket = "loggingb"
}
resource "aws_dynamodb_table" "terraform_locks" {
  name         = "dynmodb"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }
}

terraform {
  backend "s3" {
    bucket         = "s3bucketwiskey"
    key            = "global/s3/terraform.tfstate"
    region         = "eu-west-2"
    dynamodb_table = "dynmodb"
    encrypt        = true
  }
}