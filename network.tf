resource "aws_vpc" "myvpc"{
    cidr_block = "10.0.0.0/16"
    tags = {
        Name = "MyVPC"
    }
}
resource "aws_subnet" "PublicSubnet"{
    vpc_id = aws_vpc.myvpc.id
    availability_zone = "us-east-2a"
    cidr_block = "10.0.1.0/24"
}    
resource "aws_subnet" "PrivateDbSubnet" {
  vpc_id            = aws_vpc.myvpc.id
  availability_zone =  "us-east-2a"
  cidr_block        = "10.0.2.0/24"
  map_public_ip_on_launch = false
}

resource "aws_subnet" "PrivateAppSubnet" {
  vpc_id            = aws_vpc.myvpc.id
  availability_zone = "us-east-2a" 
  cidr_block        = "10.0.3.0/24"
  map_public_ip_on_launch = false  
}
resource "aws_subnet" "PrivateAppSubnet2" {
  vpc_id            = aws_vpc.myvpc.id
  availability_zone = "us-east-2b"    
  cidr_block        = "10.0.4.0/24"
  map_public_ip_on_launch = false
}

# Create Internet Gateway and Attach it to VPC
resource "aws_internet_gateway" "myIgw"{
    vpc_id = aws_vpc.myvpc.id
}

# Create Route Table and Add Public Route
resource "aws_route_table" "PublicRT"{
    vpc_id = aws_vpc.myvpc.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.myIgw.id
    }
}
#Associate Public Subnet to "Public Route Table"
resource "aws_route_table_association" "PublicRTAssociation"{
    subnet_id = aws_subnet.PublicSubnet.id
    route_table_id = aws_route_table.PublicRT.id
}

resource "aws_security_group" "gogs-prod" {
  vpc_id = aws_vpc.myvpc.id
  name = "gogs-secgroup"
  description = "App security group"
  egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }
}

