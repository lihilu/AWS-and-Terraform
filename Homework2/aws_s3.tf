resource "aws_s3_bucket" "terraform_state" {
  bucket = "s3bucketwiskey"
  # Enable versioning so we can see the full revision history of our
  # state files
  versioning {
    enabled = true
  }
   logging {
    target_bucket = aws_s3_bucket.loggingb.id
    target_prefix = "log/"
  }
  # Enable server-side encryption by default
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

resource "aws_s3_bucket" "loggingb" {
  bucket = "loggingb"
  acl    = "log-delivery-write"
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
