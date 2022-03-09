resource "aws_iam_role" "s3admin" {
  name        = "s3admin"
  assume_role_policy =<<EOF
{
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action":"sts:AssumeRole",
        "Principal": {
          "Service": "ec2.amazonaws.com"
        },
        "Effect":"Allow",
        "Sid": ""
      }
    ]
  }
EOF
}

resource "aws_iam_instance_profile" "admin" {
    name = "s3admin"
    role = "${aws_iam_role.s3admin.name}" 
}

resource "aws_iam_role_policy" "adminrolepo" {
    name = "adminrolepo"
    role = "${aws_iam_role.s3admin.id}"
    policy = <<EOT
{
  "Version": "2012-10-17",
  "Statement": [
    {
        "Effect": "Allow",
        "Action": [
           "s3:*"
        ],
        "Resource": [
            "arn:aws:s3:::s3bucketwiskey",
            "arn:aws:s3:::s3bucketwiskey/*"
        ]
    },
    {
      "Effect": "Allow",
      "Action": "s3:*",
      "Resource": "arn:aws:s3:::*"
    }
  ]
}
EOT
}

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
