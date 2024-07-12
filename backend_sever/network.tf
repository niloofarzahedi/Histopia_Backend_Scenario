#avalability zones
data "aws_availability_zones" "avalability_zones" {
  state = "available"
}
#vpc
resource "aws_vpc" "histopia" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
}
#subnets
resource "aws_subnet" "histopia" {
  vpc_id                  = aws_vpc.histopia.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.avalability_zones.names[0]
}
#internet gateway
resource "aws_internet_gateway" "histopia" {
  vpc_id = aws_vpc.histopia.id
}
#route table
resource "aws_route_table" "histopia" {
  vpc_id = aws_vpc.histopia.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.histopia.id
  }
}
#route table association
resource "aws_route_table_association" "histopia" {
  route_table_id = aws_route_table.histopia.id
  subnet_id      = aws_subnet.histopia.id
}
#instance security group
resource "aws_security_group" "histopia" {
  name   = "histopia_sg"
  vpc_id = aws_vpc.histopia.id

  # HTTP access from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  #ICMP access from anywhere
  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  #ssh access from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Caution: This allows SSH from any IP. Consider limiting to specific IPs.
  }
  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#alb security group
