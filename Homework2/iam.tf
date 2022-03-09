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