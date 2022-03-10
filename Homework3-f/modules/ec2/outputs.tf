output "public_ip" {
  value = aws_instance.ec2_web
}

output "private_ip" {
  value = aws_instance.ec2_db
}


output "instance_id" {
  value = aws_instance.ec2_web.*.id
}