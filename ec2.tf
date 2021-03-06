provider "aws" {
  access_key = "AKIARKDIT5BHRQGXXXXX"
  secret_key = "dKvQzS6A6LaiRXXXXXXXrtwi8EIyXXXXXXeXXqh2"
  region     = "ap-southeast-1"
}

resource "aws_launch_configuration" "stockbit" {
  name_prefix = "stockbit-"
  image_id      = "ami-01581ffba3821cdf3"
  instance_type = "t2.medium"
}

resource "aws_vpc" "stockbit-vpc" {
  cidr_block       = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true 
tags = {
  Name = "Stockbit VPC"
}
}

resource "aws_eip" "stockbit-vpc-nat"{
  vpc = true

  associate_with_private_ip = "10.0.0.12"
}

resource "aws_nat_gateway" "nat-gw-stockbit" {
  allocation_id = aws_eip.stockbit-vpc-nat.id
  subnet_id = aws_subnet.private.id
tags = {
  Name = "GW NAT"
}
}
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.stockbit-vpc.id
tags = {
  Name = "IGW Stockbit"
}
}



resource "aws_subnet" "private" {
  vpc_id     = aws_vpc.stockbit-vpc.id
  cidr_block = "10.0.1.0/24"
tags = {
  Name = "Private PVC"
}
}

resource "aws_subnet" "public" {
  vpc_id     = aws_vpc.stockbit-vpc.id
  cidr_block = "10.0.2.0/24"
tags  = {
  Name = "public vpc"
}
}

resource "aws_route_table" "public-rt" {
  vpc_id     = aws_vpc.stockbit-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }



}



resource "aws_security_group" "allow_ssh" {
  name        = "allow_all_ssh"
  description = "Allow all inbound ssh traffic "

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

resource "aws_autoscaling_group" "stockbit-autoscaling" {
name = "${aws_launch_configuration.stockbit.name}-asg"
vpc_zone_identifier = [aws_subnet.private.id]
launch_configuration = aws_launch_configuration.stockbit.name
min_size = 2
max_size = 5
health_check_grace_period = 300
health_check_type = "EC2"
force_delete = true

tag {
key = "Name"
value = "ec2 instance"
propagate_at_launch = true
}
}
