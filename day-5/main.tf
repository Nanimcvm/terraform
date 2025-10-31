resource "aws_vpc" "name" {
  cidr_block = "10.0.0.0/16"
  region = "ap-south-1"
  tags = {
    Name = "Day-5-vpc"
  }
  lifecycle {
    ignore_changes = [ tags, ]
  }
}

resource "aws_subnet" "name1" {
  cidr_block = "10.0.0.0/20"
  vpc_id = aws_vpc.name.id
  tags = {
    Name = "subnet-1"
  }
  lifecycle {
    ignore_changes = [ tags, ]
  }
}

resource "aws_subnet" "name2" {
  cidr_block = "10.0.16.0/20"
  vpc_id = aws_vpc.name.id
  tags = {
    Name = "subnet-2"
  }
  lifecycle {
    ignore_changes = [ tags, ]
  }
}

resource "aws_subnet" "name3" {
  cidr_block = "10.0.32.0/20"
  vpc_id = aws_vpc.name.id
  tags = {
    Name = "subnet-3"
  }
  lifecycle {
    ignore_changes = [ tags, ]
  }
}

resource "aws_subnet" "name4" {
  cidr_block = "10.0.48.0/20"
  vpc_id = aws_vpc.name.id
  tags = {
    Name = "subnet-4"
  }
  lifecycle {
    ignore_changes = [ tags, ]
  }
}

resource "aws_internet_gateway" "name" {
  vpc_id = aws_vpc.name.id
  tags = {
    Name = "Terra_ig"
  }
  lifecycle {
    ignore_changes = [ tags, ]
  }
}

resource "aws_eip" "name" {
    domain = "vpc"

  tags = {
    Name = "nat-eip"
  }
  lifecycle {
    ignore_changes = [ tags, ]
  }
}

resource "aws_nat_gateway" "name" {
  subnet_id = aws_subnet.name1.id
  allocation_id = aws_eip.name.id
  tags = {
    Name = "Terra_nat"
  }
  lifecycle {
    ignore_changes = [ tags, ]
  }
}

resource "aws_route_table" "pub" {
  vpc_id = aws_vpc.name.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.name.id
  }
  
  tags = {
    Name = "public_rt"
  }
  lifecycle {
    ignore_changes = [ tags, ]
  }
}

resource "aws_route_table_association" "pub1" {
  subnet_id = aws_subnet.name1.id
  route_table_id = aws_route_table.pub.id
}

resource "aws_route_table_association" "pub2" {
  subnet_id = aws_subnet.name2.id
  route_table_id = aws_route_table.pub.id
}

resource "aws_route_table" "pri" {
  vpc_id = aws_vpc.name.id
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.name.id
  }
  tags = {
    Name = "private_rt"
  }
  lifecycle {
    ignore_changes = [ tags, ]
  }
}

resource "aws_route_table_association" "pri1" {
  subnet_id = aws_subnet.name3.id
  route_table_id = aws_route_table.pri.id
}

resource "aws_route_table_association" "pri2" {
  subnet_id = aws_subnet.name4.id
  route_table_id = aws_route_table.pri.id
}
 resource "aws_security_group" "name" {
   vpc_id = aws_vpc.name.id
   ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
   }

   ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
   }

   ingress {
    description = "MySql"
    from_port = 3036
    to_port = 3036
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
   }
    egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "terra_sg"
  }
  lifecycle {
    ignore_changes = [ tags, ]
  }
 }

resource "aws_instance" "pub" {
  ami = "ami-01760eea5c574eb86"
  subnet_id = aws_subnet.name1.id
  instance_type = "t3.micro"
  vpc_security_group_ids = [aws_security_group.name.id]
  associate_public_ip_address = true
  tags = {
    Name = "public instance"
  }
  lifecycle {
    ignore_changes = [ tags, ]
  }
}

resource "aws_instance" "pri" {
  ami = "ami-01760eea5c574eb86"
  subnet_id = aws_subnet.name3.id
  instance_type = "t3.micro"
  vpc_security_group_ids = [aws_security_group.name.id]
  tags = {
    Name = "private instance"
  }
  lifecycle {
    ignore_changes = [ tags, ]
  }
}

resource "aws_instance" "pri2" {
  ami = "ami-01760eea5c574eb86"
  subnet_id = aws_subnet.name3.id
  instance_type = "t3.micro"
  vpc_security_group_ids = [aws_security_group.name.id]
  tags = {
    Name = "private instance2"
  }
  lifecycle {
    ignore_changes = [ tags, ]
  }
}