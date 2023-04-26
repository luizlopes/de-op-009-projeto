# Cria uma VPC, um tipo de rede privada dentro da AWS.
resource "aws_vpc" "dev-vpc" {
  cidr_block = var.cidr_block

  tags = {
    Name = "vpc-${var.tag-sufix-name}"
  }
}

resource "aws_subnet" "private-subnet" {
  count             = var.subnet_count
  vpc_id            = aws_vpc.dev-vpc.id
  cidr_block        = var.subnet_cidr_block[count.index]
  availability_zone = var.subnet_az[count.index]

  tags = {
    Name = "subnet-${var.tag-sufix-name}-${count.index + 1}"
  }
}
