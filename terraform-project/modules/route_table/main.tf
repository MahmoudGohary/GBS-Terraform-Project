resource "aws_route_table" "public" {
  vpc_id = var.vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = var.igw_id
  }
}

resource "aws_route_table" "private" {
  vpc_id = var.vpc_id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = var.nat_gateway_id
  }
}

resource "aws_route_table_association" "public_subnet_1" {
  subnet_id      = var.public_subnets[0]
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_subnet_2" {
  subnet_id      = var.public_subnets[1]
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private_subnet_1" {
  subnet_id      = var.private_subnets[0]
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private_subnet_2" {
  subnet_id      = var.private_subnets[1]
  route_table_id = aws_route_table.private.id
}