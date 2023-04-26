output "vpc_id" {
    value = aws_vpc.dev-vpc.id
}

output "subnet_ids" {
  value = aws_subnet.private-subnet
}

output "vpc_cidr_block" {
  value = aws_vpc.dev-vpc.cidr_block
}
