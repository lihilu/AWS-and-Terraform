output "public_ip" {
  value = aws_instance.ec2_web
}

output "private_ip" {
  value = aws_instance.ec2_db
}