variable "ami_id" {
    description = "passing ami values"
    default = "ami-00af95fa354fdb788"
    type = string
  
}
variable "type" {
    description = "passing values to instance type"
    default = "t3.micro"
    type = string
  
}