data "aws_ami" "example" {
  #executable_users = ["self"]
  most_recent = true
  #name_regex       = "^myami-\\d{3}"
  owners = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-kernel-*-hvm-*-x86_64-gp2"] # this was plucked from her notepad in her 20:35 youtube
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

data "aws_availability_zones" "azs" {

}




#ami_value = "ami-0fc5d935ebf8bc3bc"
#instance_type_value = "t2.micro"
