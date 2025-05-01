resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.eip_for_nat.id
  subnet_id     = aws_subnet.public_subnets[0].id

  tags = {
    Name = "gw NAT"
  }


  depends_on = [aws_internet_gateway.igw]
}