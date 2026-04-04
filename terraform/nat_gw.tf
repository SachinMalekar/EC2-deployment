
# elastic ip 
resource "aws_eip" "ngw_eip" {
  domain = "vpc"
}

# NAT gateway
resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.ngw_eip.id
  subnet_id     = aws_subnet.public_subet_a.id

  tags = {
    Name = "nat_gw"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.dev_igw]
}

resource "aws_route_table" "private_rtb" {
  vpc_id = aws_vpc.dev_vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw.id
  }

  tags = {
    Name = "private_rtb"
  }
}

# route table subet association , private-a
resource "aws_route_table_association" "rtb_assoc_private_subnet_a" {
  subnet_id      = aws_subnet.private_subet_a.id
  route_table_id = aws_route_table.private_rtb.id
}

# route table subet association , private-b
resource "aws_route_table_association" "rtb_assoc_private_subnet_b" {
  subnet_id      = aws_subnet.private_subet_b.id
  route_table_id = aws_route_table.private_rtb.id
}
