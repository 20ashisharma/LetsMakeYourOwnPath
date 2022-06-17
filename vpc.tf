resource "aws_vpc" "sushantvpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "sushantvpc"
  }
}

resource "aws_subnet" "sushantpublic" {
  vpc_id     = aws_vpc.sushantvpc.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "sushantpublic"
  }
}

resource "aws_subnet" "sushantprivate" {
  vpc_id     = aws_vpc.sushantvpc.id
  cidr_block = "10.0.2.0/24"

  tags = {
    Name = "sushantprivate"
  }
}

################ IG For VPV ##################
resource "aws_internet_gateway" "sushantgw" {
  vpc_id = aws_vpc.sushantvpc.id

  tags = {
    Name = "sushantgw"
  }
}
############# Route table for public subnet############

resource "aws_route_table" "publicroute" {
  vpc_id = aws_vpc.sushantvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.sushantgw.id
  }

  tags = {
    Name = "publicroute"
  }
}
################ Route table for private subnet #########

 resource "aws_route_table" "privateroute" {   
   vpc_id = aws_vpc.sushantvpc.id
   route {
   cidr_block = "0.0.0.0/0"             # Traffic from Private Subnet reaches Internet via NAT Gateway
   nat_gateway_id = aws_nat_gateway.NATgw.id
   }
 }
#####  Create EIP FOR NAT
  resource "aws_eip" "nateIP" {
   vpc   = true
 }
 #######  Creating the NAT Gateway using subnet_id and allocation_id
 resource "aws_nat_gateway" "NATgw" {
   allocation_id = aws_eip.nateIP.id
   subnet_id = aws_subnet.sushantpublic.id
 }

terraform {
  backend "s3" {
    bucket = "tfstateot"
    key    = "dev/terraform.tfstate"
    region = "ap-south-1"
    profile = "sushant"
  }
}


 #######  Route table Association with Public Subnet's
 resource "aws_route_table_association" "PublicRTassociation" {
    subnet_id = aws_subnet.sushantpublic.id
    route_table_id = aws_route_table.publicroute.id
 }
 ########  Route table Association with Private Subnet's
 resource "aws_route_table_association" "PrivateRTassociation" {
    subnet_id = aws_subnet.sushantprivate.id
    route_table_id = aws_route_table.privateroute.id
 }


