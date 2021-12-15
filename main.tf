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
#Create Route Table
resource "aws_route_table" "SR-RouteTable" {
   vpc_id = aws_vpc.SR-VPC.id 
   route {
      cidr_block = "0.0.0.0/0"
      gateway_id = aws_internet_gateway.SR-igw.id   
   }  
   tags = {
       Name = "SR-RouteTable"
   }
}
#Create Route Association
resource "aws_route_table_association" "SR-RouteAssociationSubnet" {
    subnet_id = aws_subnet.SR-Subnet.id
    route_table_id = aws_route_table.SR-RouteTable.id
}

#Create Security Groups
resource "aws_security_group" "allow_80" {
    name = "allow_80"
    description = "Allows TLS inbounb traffic"
    vpc_id = aws_vpc.SR-VPC.id

    ingress {
        description      = "TLS from VPC"
        from_port        = 80
        to_port          = 80
        protocol         = "tcp"
        cidr_blocks      = [aws_vpc.SR-VPC.cidr_block]
  }

    egress {
        from_port        = 0
        to_port          = 0
        protocol         = "-1"
        cidr_blocks      = ["0.0.0.0/0"]
    }

  tags = {
    Name = "allow_80"
  }
}

# Create a Security Group for SSH
resource "aws_security_group" "allow_22" {
  name = "allow_22"
  description = "allows SSH: 22"
  vpc_id = aws_vpc.SR-VPC.id

  ingress {
    description = "SSH: 22 from VPC"
    from_port = 22
    to_port = 22
    protocol = "TCP"
    cidr_blocks = [aws_vpc.SR-VPC.cidr_block]
  }

   egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  tags = {
      Name = "allow_22"
  }
}

#Create EC2 instance
resource "aws_instance" "SR-EC2-Instance" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"

  tags = {
    Name = "HelloWorld"
  }
}