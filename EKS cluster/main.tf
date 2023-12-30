module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "jenkins-vpc"
  cidr = var.vpc_cidr

  azs             = data.aws_availability_zones.azs.names
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets
  # map_public_ip_on_launch = true #this was not here initially  and ended up unable to connect at EC2 'connect' pubip:8080

  enable_dns_hostnames = true
  enable_nat_gateway   = true
  single_nat_gateway   = true

  #   enable_vpn_gateway = true

  tags = {
    "kubernetes.io/cluster/my-eks-cluster" = "shared"
  }

  public_subnet_tags = {
    "kubernetes.io/role/elb"               = 1
    "kubernetes.io/cluster/my-eks-cluster" = "shared"
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb"      = 1
    "kubernetes.io/cluster/my-eks-cluster" = "shared"

  }

}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.0"

  cluster_name    = "my-eks-cluster"
  cluster_version = "1.27"

  cluster_endpoint_public_access = true


  vpc_id                   = module.vpc.vpc_id
  subnet_ids               = module.vpc.private_subnets # pprivate , because we want to deploy them in private vpc
  control_plane_subnet_ids = ["subnet-xyzde987", "subnet-slkjf456", "subnet-qeiru789"]

  #   # Self Managed Node Group(s)
  #   self_managed_node_group_defaults = {
  #     instance_type                          = "m6i.large"
  #     update_launch_template_default_version = true
  #     iam_role_additional_policies = {
  #       AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  #     }
  #   }

  #   self_managed_node_groups = {
  #     one = {
  #       name         = "mixed-1"
  #       max_size     = 5
  #       desired_size = 2

  #       use_mixed_instances_policy = true
  #       mixed_instances_policy = {
  #         instances_distribution = {
  #           on_demand_base_capacity                  = 0
  #           on_demand_percentage_above_base_capacity = 10
  #           spot_allocation_strategy                 = "capacity-optimized"
  #         }

  #         override = [
  #           {
  #             instance_type     = "m5.large"
  #             weighted_capacity = "1"
  #           },
  #           {
  #             instance_type     = "m6i.large"
  #             weighted_capacity = "2"
  #           },
  #         ]
  #       }
  #     }
  #   }

  # EKS Managed Node Group(s)
  #   eks_managed_node_group_defaults = {
  #     instance_types = ["m6i.large", "m5.large", "m5n.large", "m5zn.large"]
  #   }

  eks_managed_node_groups = {

    Node = {
      min_size      = 1
      max_size      = 3
      desired_size  = 2
      instance_type = ["t2.medium"]
    }
    # blue = {}
    # green = {
    #   min_size     = 1
    #   max_size     = 10
    #   desired_size = 1

    #   instance_types = ["t3.large"]
    #   capacity_type  = "SPOT"
    # }
  }

  #   # Fargate Profile(s)
  #   fargate_profiles = {
  #     default = {
  #       name = "default"
  #       selectors = [
  #         {
  #           namespace = "default"
  #         }
  #       ]
  #     }
  #   }

  # aws-auth configmap
  #   manage_aws_auth_configmap = true

  #   aws_auth_roles = [
  #     {
  #       rolearn  = "arn:aws:iam::66666666666:role/role1"
  #       username = "role1"
  #       groups   = ["system:masters"]
  #     },
  #   ]

  #   aws_auth_users = [
  #     {
  #       userarn  = "arn:aws:iam::66666666666:user/user1"
  #       username = "user1"
  #       groups   = ["system:masters"]
  #     },
  #     {
  #       userarn  = "arn:aws:iam::66666666666:user/user2"
  #       username = "user2"
  #       groups   = ["system:masters"]
  #     },
  #   ]

  #   aws_auth_accounts = [
  #     "777777777777",
  #     "888888888888",
  #   ]

  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}

