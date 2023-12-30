terraform {
  backend "s3" {
    bucket = "howtobucket"
    key    = "jenkins2/terraform.tfstate"
    region = "us-east-1" # make sure to not use variables in this blk, recom use actual values
  }
}