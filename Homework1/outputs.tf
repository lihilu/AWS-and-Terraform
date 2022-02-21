output "instance_public_ips" {
  value       =  join(",",concat(aws_instance.ec2.*.public_ip))
  description = "The public IP address of server instance."
}

