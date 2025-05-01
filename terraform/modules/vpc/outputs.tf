output "vpc_id" {
  value = aws_vpc.main.id
}

output "private_subnets" {
  value = aws_subnet.private_subnets[*].id
}

output "public_subnets" {
  value = aws_subnet.public_subnets[*].id
}

output "igw_id" {
  value = aws_internet_gateway.igw.id
}

output "internet_rt_id" {
  value = aws_route_table.internet.id
}