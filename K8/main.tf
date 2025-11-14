
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "EKS-VPC"
  cidr = var.cidr_block

  azs             = ["us-east-1a"]
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnet

  enable_nat_gateway   = true
  enable_dns_hostnames = true


  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
  public_subnet_tags = {
    "kubernetes.i/o cluster" = "shared "
  }
  private_subnet_tags = {
    "kubernetes.i/o cluster" = "shared "
  }
}
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.0"

  name               = "my-cluster"
  kubernetes_version = "1.33"






  # Optional: Adds the current caller identity as an administrator via cluster access entry
  enable_cluster_creator_admin_permissions = true

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets




  # EKS Managed Node Group(s)
  eks_managed_node_groups = {
    example = {
      # Starting on 1.30, AL2023 is the default AMI type for EKS managed node groups
      ami_id         = "ami-0cae6d6fe6048ca2c"
      instance_types = ["t3.small"]

      min_size     = 1
      max_size     = 3
      desired_size = 2
    }
  }

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}




