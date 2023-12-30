terraform {
  backend "s3" {
    bucket = "howtobucket"
    key    = "eks/terraform.tfstate"
    region = "us-east-1"

  }
}