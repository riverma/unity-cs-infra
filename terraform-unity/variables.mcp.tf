#variable "ami_name" { default = "unity-github-runner" }
#variable "ami_id" { default = "ami-04505e74c0741db8d" }
#variable "ami_key_pair_name" { default = "barber-unity-pair" }

variable "ami_name" { default = "unity-ubuntu" }
variable "ami_id" { default = "ami-0688ba7eeeeefe3cd" }
#variable "ami_id" { default = "ami-04505e74c0741db8d" }
variable "ami_key_pair_name" { default = "unity-cs-mcp-smolensk" }
variable "vpc_id" { default = "vpc-0106218dbddd3a753" }

data "aws_vpc" "unity-test-env" {
  id         = var.vpc_id
  cidr_block = "10.52.8.0/22"
}

// Use existing subnets from MCP
data "aws_subnet" "subnet-uno" {
  id = "subnet-059bc4f467275b59d"
}

data "aws_subnet" "subnet-two" {
  id = "subnet-0ebdd997cc3ebe58d"
}
