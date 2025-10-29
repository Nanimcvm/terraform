terraform {
  backend "s3" {
    bucket = "gangadevopsnit"
    key    = "terraform.tfstate"
    region = "ap-south-1"
  }
}
