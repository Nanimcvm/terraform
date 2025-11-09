variable "ami_id" {
    description = "passing ami values"
    default = "ami-0305d3d91b9f22e84"
    type = string
  
}
variable "type" {
    description = "passing values to instance type"
    default = "t3.micro"
    type = string
  
}