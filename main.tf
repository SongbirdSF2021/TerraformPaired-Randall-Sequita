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
  map_public_ip_on_launch = true
 
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
  ami = "ami-0ed9277fb7eb570c9"
  instance_type = "t2.micro"
  # VPC
  subnet_id = "${aws_subnet.SR-Subnet.id}"
  # Security Group
  vpc_security_group_ids = ["${aws_security_group.allow_22.id}"]
  # the Public SSH key
  key_name = "SB-EC2-Excercise"
  
  tags = {
    Name = "SR-EC2-Instance"
  }
  user_data = "${file("install.sh")}"
}

#Create output variable for EC2 IPv4 address
output "SR-Subnet" {
    value = aws_subnet.SR-Subnet.cidr_block
}

