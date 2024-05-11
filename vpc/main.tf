resource "aws_internet_gateway" "gw" {
    vpc_id = aws_vpc.main.id  # Id of the VPC after creating it
 tags = {
    terraform = "true"
    Name = var.project_name  # Creating the VPC with name myvpc
    Environment = "Dev"
  }
}

resource "aws_subnet" "main" {
    vpc_id = aws_vpc.main.id  # Id of the VPC after creating it
    cidr_block = "10.0.1.0/24"
tags = { 
    terraform = "true"
    Name = "${var.project_name}_public_subnet"
    Environment = "Dev"
  }

}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.main.id

  route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.gw.id
  }
  tags = { 
        terraform = "true"
        Name = "${var.project_name}_public_route_table"
        Environment = "Dev"
  }

}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.main.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_subnet" "private_subnet" {
    vpc_id = aws_vpc.main.id  # Id of the VPC after creating it
    cidr_block = "10.0.11.0/24"
tags = { 
    terraform = "true"
    Name = "${var.project_name}_private_subnet"
    Environment = "Dev"
  }

}

resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.main.id

  tags = { 
        terraform = "true"
        Name = "${var.project_name}_private_route_table"
        Environment = "Dev"
  }

}

resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.private_route_table.id
}

resource "aws_subnet" "database_subnet" {
    vpc_id = aws_vpc.main.id  # Id of the VPC after creating it
    cidr_block = "10.0.21.0/24"
tags = { 
    terraform = "true"
    Name = "${var.project_name}_database_subnet"
    Environment = "Dev"
  }

}

resource "aws_route_table" "database_route_table" {
  vpc_id = aws_vpc.main.id

  tags = { 
        terraform = "true"
        Name = "${var.project_name}_database_route_table"
        Environment = "Dev"
  }

}

resource "aws_route_table_association" "database" {
  subnet_id      = aws_subnet.database_subnet.id
  route_table_id = aws_route_table.database_route_table.id
}

resource "aws_eip" "nat" {
  domain   = "vpc"
}

resource "aws_nat_gateway" "natgateway" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.main.id

  tags = {
    Name = "gw NAT"
  }
}

resource "aws_route" "private" {
  route_table_id            = aws_route_table.private_route_table.id
  destination_cidr_block    = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.natgateway.id
}

resource "aws_route" "database" {
  route_table_id            = aws_route_table.database_route_table.id
  destination_cidr_block    = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.natgateway.id
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  instance_tenancy = "default"
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    terraform = "true"
    Name = "myvpc"  # Creating the VPC with name myvpc
    Environment = "Dev"
  }
}

