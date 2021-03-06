output "s3_bucket_arn" {
  value       = aws_s3_bucket.terraform_state.arn
  description = "The ARN of the S3 bucket"
}
output "dynamodb_table_name" {
  value       = aws_dynamodb_table.terraform_locks.name
  description = "The name of the DynamoDB table"
}


output "instance_public_ips" {
  value       =  join(",",concat(aws_instance.nginx.*.public_ip))
  description = "The public IP address of server instance."
}



output "user_data" {
  value       =  aws_instance.nginx.*.user_data
  description = "user data"
}