output "vpc" {
  value = aws_vpc.vpc
}

output "sg_pub_id" {
  value = aws_security_group.nginx_instances_access.id
}

output "sg_priv_id" {
  value = aws_security_group.DB_instnaces_access.id
}

output "subnet_public_id" {
  value = aws_subnet.public.*.id
  
}

output "aws_subnet_private" {
  value = aws_subnet.private.*.id
  
}
