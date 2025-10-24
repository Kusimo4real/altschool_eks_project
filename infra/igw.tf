resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.altsch_vpc.id

  tags = {
    Name = "${local.env}-igw"
  }
}