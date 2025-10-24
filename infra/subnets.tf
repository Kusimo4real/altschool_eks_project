# resource "aws_subnet" "private_az1" {
#   vpc_id            = aws_vpc.altsch_vpc.id
#   cidr_block        = "10.0.0.128/26"
#   availability_zone = local.zone1

#   tags = {
#     Name                                                   = "${local.env}-private_subnet-${local.zone1}"
#     "kubernetes.io/role/internal-elb"                      = "1"
#     "kubernetes.io/cluster/${local.env}-${local.eks_name}" = "owned"
#   }
# }

# resource "aws_subnet" "private_az2" {
#   vpc_id            = aws_vpc.altsch_vpc.id
#   cidr_block        = "10.0.0.192/26"
#   availability_zone = local.zone2

#   tags = {
#     Name                                                   = "${local.env}-private_subnet-${local.zone2}"
#     "kubernetes.io/role/internal-elb"                      = "1"
#     "kubernetes.io/cluster/${local.env}-${local.eks_name}" = "owned"
#   }
# }

resource "aws_subnet" "public_az1" {
  vpc_id                  = aws_vpc.altsch_vpc.id
  cidr_block              = "10.0.0.0/26"
  availability_zone       = local.zone1
  map_public_ip_on_launch = true

  tags = {
    Name                                                   = "${local.env}-public_subnet-${local.zone1}"
    "kubernetes.io/role/elb"                               = "1"
    "kubernetes.io/cluster/${local.env}-${local.eks_name}" = "owned"
  }
}

resource "aws_subnet" "public_az2" {
  vpc_id                  = aws_vpc.altsch_vpc.id
  cidr_block              = "10.0.0.64/26"
  availability_zone       = local.zone2
  map_public_ip_on_launch = true

  tags = {
    Name                                                   = "${local.env}-public_subnet-${local.zone2}"
    "kubernetes.io/role/elb"                               = "1"
    "kubernetes.io/cluster/${local.env}-${local.eks_name}" = "owned"
  }
}

