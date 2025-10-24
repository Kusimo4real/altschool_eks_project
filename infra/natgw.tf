# resource "aws_eip" "natgw" {
#   domain = "vpc"

#   tags = {
#     Name = "${local.env}-natgw"
#   }
# }

# resource "aws_nat_gateway" "natgw" {
#   allocation_id = aws_eip.natgw.id
#   subnet_id = aws_subnet.public_az1.id

#   tags = {
#     Name = "${local.env}-nat"
#   }
# }