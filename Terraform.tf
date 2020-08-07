provider "aws" {
  access_key = var.access_key
  secret_key = var.secret_key
  region = var.region
}

data "aws_availability_zones" "available" {
  state = "available"
  exclude_names = ["us-east-1a"]
}

resource "aws_vpc" "my_vpc" {
  cidr_block = var.cidr_block
  tags = {
    Name = "my_vpc"
  }
}

resource "aws_subnet" "subnet_0" {
  vpc_id = aws_vpc.my_vpc.id
  cidr_block = var.cidr_subnet_0
  map_public_ip_on_launch = true
  availability_zone = data.aws_availability_zones.available.names[0]
  tags = {
    Name = "my_subnet_0"
  }
  
}

resource "aws_subnet" "subnet_1" {
  vpc_id = aws_vpc.my_vpc.id
  cidr_block = var.cidr_subnet_1
  map_public_ip_on_launch = true
  availability_zone = data.aws_availability_zones.available.names[1]
  tags = {
    Name = "my_subnet_1"
  }
}

resource "aws_internet_gateway" "my_gateway" {
  vpc_id = aws_vpc.my_vpc.id
  tags = {
    Name = "my_gateway"
  }
}

resource "aws_route_table" "my_table" {
  vpc_id = aws_vpc.my_vpc.id
  tags = {
    Name = "my_table"
  }
}

resource "aws_route" "my_route" {
  route_table_id = aws_route_table.my_table.id
  gateway_id = aws_internet_gateway.my_gateway.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route_table_association" "rt_0" {
  subnet_id = aws_subnet.subnet_0.id
  route_table_id = aws_route_table.my_table.id
}

resource "aws_route_table_association" "rt_1" {
  subnet_id = aws_subnet.subnet_1.id
  route_table_id = aws_route_table.my_table.id
}

resource "aws_iam_role" "my_cluster_role" {
  name = "my_cluster_role"
  assume_role_policy = <<POLICY
{
    "Version": "2012-10-17",
	"Statement": [
	  {
	    "Action": "sts:AssumeRole",
	    "Principal": {
		  "Service": "eks.amazonaws.com"
		},
        "Effect": "Allow"		
      }
	]
}
  POLICY
}

resource "aws_iam_role_policy_attachment" "p_0" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role = aws_iam_role.my_cluster_role.name
}

resource "aws_iam_role" "my_node_role" {
  name = "my_node_role"
  assume_role_policy = <<POLICY
{
    "Version": "2012-10-17",
	"Statement": [
	  {
	    "Action": "sts:AssumeRole",
	    "Principal": {
		  "Service": "ec2.amazonaws.com"
		},
        "Effect": "Allow"		
      }
	]
}
  POLICY
}

resource "aws_iam_role_policy_attachment" "p_1" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role = aws_iam_role.my_node_role.name
}

resource "aws_iam_role_policy_attachment" "p_2" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role = aws_iam_role.my_node_role.name
}

resource "aws_iam_role_policy_attachment" "p_3" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role = aws_iam_role.my_node_role.name
}

resource "aws_security_group" "my_sg" {
  name = "my_sg"
  description = "Test SG"
  vpc_id = aws_vpc.my_vpc.id
  tags = {
    Name = "my_sg"
  }
}

resource "aws_security_group_rule" "AllowSelf_In" {
  type = "ingress"
  from_port = 0
  to_port = 65535
  protocol = "all"
  security_group_id = aws_security_group.my_sg.id
  self = true
}

resource "aws_security_group_rule" "AllowAll_Out" {
  type = "egress"
  from_port = 0
  to_port = 65535
  protocol = "all"
  security_group_id = aws_security_group.my_sg.id
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_eks_cluster" "my_cluster" {
  name = "my_cluster"
  role_arn = aws_iam_role.my_cluster_role.arn
  vpc_config {
    subnet_ids = [aws_subnet.subnet_0.id, aws_subnet.subnet_1.id]
  }
  depends_on = [
    aws_iam_role_policy_attachment.p_0
  ]
}

resource "aws_eks_node_group" "my_workers" {
  cluster_name = aws_eks_cluster.my_cluster.name
  node_group_name = "my_workers"
  node_role_arn = aws_iam_role.my_node_role.arn
  subnet_ids = [aws_subnet.subnet_0.id, aws_subnet.subnet_1.id]
  disk_size = 4
  instance_types = ["t3.micro"]
  scaling_config {
    desired_size = 2
	max_size = 2
	min_size = 2
  }
  tags = {
    Name = "my_workers"
  }  
  depends_on = [
    aws_iam_role_policy_attachment.p_1,
    aws_iam_role_policy_attachment.p_2,
    aws_iam_role_policy_attachment.p_3
  ]
}

resource "null_resource" "init" {
  provisioner "local-exec" {
    command = "echo 'Done!'"
	on_failure = continue
  }
  depends_on = [
    aws_eks_node_group.my_workers,
	aws_eks_cluster.my_cluster
  ]
} 
