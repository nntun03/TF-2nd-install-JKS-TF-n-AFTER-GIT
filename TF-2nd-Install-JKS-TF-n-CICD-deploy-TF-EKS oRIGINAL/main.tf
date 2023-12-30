# will not be creating modules here, but will make use of Teraform existing modules

#vpc

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "jenkins-vpc"
  cidr = var.vpc_cidr

  azs = data.aws_availability_zones.azs.names
  #private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets          = var.public_subnets
  map_public_ip_on_launch = true #this was not here initially  and ended up unable to connect at EC2 'connect' pubip:8080

  enable_dns_hostnames = true

  #   enable_nat_gateway = true
  #   enable_vpn_gateway = true

  tags = {
    Name        = "jenkins-vpc"
    Terraform   = "true"
    Environment = "dev"
  }

  public_subnet_tags = {
    Name = "jenkins-subnet1"
  }

  redshift_route_table_tags = {
    Name = "jenkins-rt"
  }

}


#sg, google 'terrform modules security group' choose the aws , of course, and 'Security group with custom rules'

module "sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "jenkins-sg"
  description = "Security group for JKS Server"
  # vpc_id      = module.vpc.default_vpc_id
  vpc_id = module.vpc.vpc_id # above failed..so changed to this

  #ingress_cidr_blocks      = ["10.10.0.0/16"]
  #ingress_rules            = ["https-443-tcp"]
  ingress_with_cidr_blocks = [
    {
      from_port   = 8080
      to_port     = 8080
      protocol    = "tcp"
      description = "http"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      #rule        = "postgresql-tcp"
      #cidr_blocks = "0.0.0.0/0"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      description = "ssh"
      cidr_blocks = "0.0.0.0/0"
    },
  ]
  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = -1
      cidr_blocks = "0.0.0.0/0"
    }
  ]

  tags = {
    Name = "jenkins-sg"
  }
}



#ec2  google 'terrform modules aws ec2 resources (in readme, not output/imput/doc etc' choose the aws , of course, 
module "ec2_instance" {
  source = "terraform-aws-modules/ec2-instance/aws"

  name = "jenkins-Server"

  instance_type               = var.instance_type
  key_name                    = "onGatewayKP"
  monitoring                  = true
  vpc_security_group_ids      = [module.sg.security_group_id] # what is the output of module.sg? smthg we need to check, UT 41:07  this was found from 'outputs' of 'terrform modules security group'
  subnet_id                   = module.vpc.public_subnets[0]  # continued  'this_security_group_id'(her v 1.19) no longer used in my version 5.1.0 
  associate_public_ip_address = true
  user_data                   = file("jenkins-install.sh") # this will be the user data on ec2 that will get installed upon launch (bootstrap)
  availability_zone           = data.aws_availability_zones.azs.names[0]

  tags = {
    Name        = "jenkins-Server2"
    Terraform   = "true"
    Environment = "dev"
  }
}