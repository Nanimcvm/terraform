variable "vpc" {
  default = ""
  description = "Vpc creation"
  type = string
}

variable "subnet" {
  default = ""
  description = "subnet creation"
  type = string
}

variable "route_table" {
  default = ""
  description = "route table created"
  type = string
}

variable "ec2" {
  default = ""
  description = "instance created"
  type = string
}
