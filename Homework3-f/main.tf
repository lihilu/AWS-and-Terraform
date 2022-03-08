module "networking" {
  source    = "./modules/networking"
  
  namespace = "pro"
}

module "public_instance" {
  source     = "./modules/ec2"
  subnet_public_id= module.networking.subnet_public_id
  subnet_private_id = module.networking.aws_subnet_private
  #count_instance=var.count_instance
  aws_vpc =  module.networking.vpc
  sg_pub_id = module.networking.sg_pub_id
  sg_priv_id  = module.networking.sg_priv_id
  key_name   = module.ssh-key.key_name
  env_name= "prod"
}



module "ssh-key" {
  source    = "./modules/ssh-key"
  namespace = var.namespace
}