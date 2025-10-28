resource "aws_vpc" "name" {
  cidr_block = var.vpc
  tags = {
    Name = "Terra_vpc"
  }
}

resource "aws_subnet" "name" {
  vpc_id = aws_vpc.name.id
  cidr_block = var.subnet
  map_public_ip_on_launch = true
  availability_zone = "ap-south-1a"
  tags = {
    Name = "subnet1"
  }
}

resource "aws_internet_gateway" "name" {
  vpc_id = aws_vpc.name.id
  tags = {
    Name = "Terra_ig"
  }
}

resource "aws_route_table" "name" {
  vpc_id = aws_vpc.name.id
  route {
    cidr_block = var.route_table
    gateway_id = aws_internet_gateway.name.id
  }
  tags = {
      Name = "Terra_pub_route"
    }
}

resource "aws_instance" "name" {
  ami = var.ec2
  instance_type = "t3.micro"
  subnet_id = aws_subnet.name.id
  tags = {
    Name = "day2_instance"
  }
}