resource "aws_instance" "name" {
  ami = "ami-0305d3d91b9f22e84"
  instance_type = "t3.micro"
  key_name = "task"
  tags = {
    Name = "day-6"
  }
}