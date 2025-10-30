terraform {
  backend "s3" {
    bucket = "gangaterraformnit"
    key    = "terraform.tfstate"
    use_lockfile = true # to use s3 native locking 1.19 version above
    region = "ap-south-1"
    #dynamodb_table = "Ganga" # any version we can use dynamodb locking 
    #encrypt = true
  }
}