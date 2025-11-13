#vpc 



module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "my-vpc"
  cidr = var.vpc_cidr


  public_subnets = var.public_subnet
  azs            = ["us-east-1a"]

  enable_dns_hostnames = true


  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
  public_subnet_tags = {
    Name = "JenkisSubnet"
  }
}



#SG
module "jenkis_sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "user-service"
  description = "Security group for user-service with custom ports open within VPC, and PostgreSQL publicly open"
  vpc_id      = module.vpc.vpc_id

  
  ingress_with_cidr_blocks = [
    {
      from_port   = 8080
      to_port     = 8080
      protocol    = "tcp"
      description = "User-service ports"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      description = "User-service ports"
      cidr_blocks = "0.0.0.0/0"
    },
  ]
  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      description = "Allow all outbound traffic"
      cidr_blocks = "0.0.0.0/0"
}]
}
  

# EC2 Instance

resource "aws_instance" "JenkinsServer" {
  ami                         = "ami-0cae6d6fe6048ca2c" # Amazon Linux 2 AMI
  instance_type               = "t3.micro"
  subnet_id                   = module.vpc.public_subnets[0]
  vpc_security_group_ids      = [module.jenkis_sg.security_group_id]
  availability_zone           = "us-east-1a"
  associate_public_ip_address = true

  user_data = file("usedata.sh")

  tags = {
    Name = "JenkinsServer"
  }
}





