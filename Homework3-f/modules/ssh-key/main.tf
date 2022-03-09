
resource "tls_private_key" "admin1" {
  algorithm = "RSA"
  rsa_bits  = 2048
}
resource "aws_key_pair" "admin1" {
  key_name   = "admin1"
  public_key = tls_private_key.admin1.public_key_openssh
}
# Save generated key pair locally
resource "local_file" "server_key" {
  sensitive_content  = tls_private_key.admin1.private_key_pem
  filename           = "admin1.pem"
}
