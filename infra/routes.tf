# resource "aws_route_table" "private-rt" {
#   vpc_id = aws_vpc.altsch_vpc.id # Replace with your actual VPC ID

#   route {
#     cidr_block = "0.0.0.0/0"            # Destination: Anywhere
#     nat_gateway_id = aws_nat_gateway.natgw.id       # Replace with your Internet Gateway ID
#   }

#   tags = {
#     Name = "${local.env}-private"
#   }
# }

resource "aws_route_table" "public-rt" {
  vpc_id = aws_vpc.altsch_vpc.id # Replace with your actual VPC ID

  route {
    cidr_block = "0.0.0.0/0"                 # Destination: Anywhere
    gateway_id = aws_internet_gateway.igw.id # Replace with your Internet Gateway ID
  }
  route {
    cidr_block = "10.0.0.0/24"
    gateway_id = "local"
  }
  tags = {
    Name = "${local.env}-public"
  }
}

# resource "aws_route_table_association" "private_az1" {
#   subnet_id      = aws_subnet.private_az1.id
#   route_table_id = aws_route_table.private-rt.id
# }

# resource "aws_route_table_association" "private_az2" {
#   subnet_id      = aws_subnet.private_az2.id
#   route_table_id = aws_route_table.private-rt.id
# }

resource "aws_route_table_association" "public_az1" {
  subnet_id      = aws_subnet.public_az1.id
  route_table_id = aws_route_table.public-rt.id
}

resource "aws_route_table_association" "public_az2" {
  subnet_id      = aws_subnet.public_az2.id
  route_table_id = aws_route_table.public-rt.id
}