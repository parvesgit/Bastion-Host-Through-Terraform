terraform {
  required_providers {
    aws = {
        source = "hashicorp/aws"
        version = "5.58.0"
    }
  }
}
provider "aws" {
  region = "us-east-1"
}
resource "aws_vpc" "myvpc" {
  cidr_block = "10.0.0.0/24"
  tags={
    Name="Terravpc"
  }
}
resource "aws_subnet" "pub" {
  vpc_id = aws_vpc.myvpc.id
  cidr_block = "10.0.0.0/25"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch =true
  tags ={
    Name="public-sub"
  }
}
resource "aws_subnet" "pvt" {
  vpc_id = aws_vpc.myvpc.id
  cidr_block = "10.0.0.128/25"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch =false
  tags ={
    Name="private-sub"
  }
}
resource "aws_route_table" "pub-rt" {
 vpc_id=aws_vpc.myvpc.id
 tags={
    Name="terra-public-rt"
 } 
}
resource "aws_route_table" "pvt-rt" {
 vpc_id=aws_vpc.myvpc.id
 tags={
    Name="terra-private-rt"
 } 
}
resource "aws_route_table_association" "name" {
  route_table_id=aws_route_table.pub-rt.id
  subnet_id=aws_subnet.pub.id
}
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.myvpc.id
  tags={
    Name="terra-igw"
  }
}
resource "aws_route" "rout1" {
  route_table_id = aws_route_table.pub-rt.id
  gateway_id= aws_internet_gateway.igw.id
  destination_cidr_block= "0.0.0.0/0"
}
resource "aws_security_group" "sg" {
  vpc_id = aws_vpc.myvpc.id
  name = "terra-sg"
  ingress{
    from_port = 0
    to_port = 0
    protocol = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress{
    from_port = 0
    to_port = 0
    protocol = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_instance" "pub-vpc" {
  ami="ami-08231d9638b26758d"
  instance_type="t2.micro"
  key_name = "keynew"
  security_groups = [aws_security_group.sg.id]
  subnet_id = aws_subnet.pub.id
  user_data = file("bastionhost.sh")
  tags = {
    Name="terra-public"
  }
}
resource "aws_instance" "pvt-vpc" {
  ami="ami-08231d9638b26758d"
  instance_type="t2.micro"
  key_name = "keynew"
  security_groups = [aws_security_group.sg.id]
  subnet_id = aws_subnet.pvt.id
  tags = {
    Name="terra-private"
  }
}



































