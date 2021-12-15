terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}

# Create a VPC
resource "aws_vpc" "SR-VPC" {
  cidr_block = "10.0.0.0/16"
  tags = {
      Name = "SR-VPC"
  }
}

resource "aws_subnet" "SR-Subnet" {
  vpc_id     = aws_vpc.SR-VPC.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "SR-Subnet"
  }
}
#Create a Internet Gateway

resource "aws_internet_gateway" "SR-igw" {
  vpc_id = aws_vpc.SR-VPC.id

  tags = {
    Name = "SR-igw"
  }
}