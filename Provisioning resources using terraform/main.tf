#Create AWS VPC
resource "aws_vpc" "djsworld-vpc" {
  cidr_block       = "10.0.0.0/16"
  
  tags = {
    Name = "DJSWORLD-VPC"
  }
}

# Public Subnet in Custom VPC
resource "aws_subnet" "public-subnet" {
  vpc_id     = aws_vpc.djsworld-vpc.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "Public Subnet"
  }
}

# Private Subnet in Custom VPC
resource "aws_subnet" "private-subnet" {
  vpc_id     = aws_vpc.djsworld-vpc.id
  cidr_block = "10.0.2.0/24"

  tags = {
    Name = "Private Subnet"
  }
}

# Create Security group allow SSH and internet to the EC2 instance
resource "aws_security_group" "djsworld-sg" {
  name        = "DJSWORLD-SG"
  description = "Allow ssh and internet connection inbound traffic"
  vpc_id      = aws_vpc.djsworld-vpc.id

  ingress {
    description      = "SSH from VPC"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "Internet from VPC"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "DJSWORLD-SG"
  }
}

# Custom internet Gateway
resource "aws_internet_gateway" "djsworld-igw" {
  vpc_id = aws_vpc.djsworld-vpc.id

  tags = {
    Name = "DJSWORLD-IGW"
  }
}

#Routing Table for the Public Custom VPC
resource "aws_route_table" "public-rt" {
  vpc_id = aws_vpc.djsworld-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.djsworld-igw.id
  }

  tags = {
    Name = "Public RT"
  }
}

#Routing Table Association to connect the Public Custom Subnet with the Routing Table
resource "aws_route_table_association" "public-rt-asso" {
  subnet_id      = aws_subnet.public-subnet.id
  route_table_id = aws_route_table.public-rt.id
}

# Web-server EC2 created 
resource "aws_instance" "web-server" {
  ami           = "ami-005f9685cb30f234b" # us-east-1
  instance_type = "t2.micro"
  user_data = file("${path.module}/script.sh")
  key_name = "jen-key"
  subnet_id = aws_subnet.public-subnet.id
  vpc_security_group_ids = [aws_security_group.djsworld-sg.id]

  tags = {
    Name = "Web Server"
  }
}

#Define Elastic IP for Web server
resource "aws_eip" "djsworld-aws-eip" {
  instance = aws_instance.web-server.id
  vpc      = true
}

# Database-server EC2 created 
resource "aws_instance" "db-server" {
  ami           = "ami-005f9685cb30f234b" # us-east-1
  instance_type = "t2.micro"
  key_name = "jen-key"
  subnet_id = aws_subnet.private-subnet.id
  vpc_security_group_ids = [aws_security_group.djsworld-sg.id]

  tags = {
    Name = "Database Server"
  }
}

#Define Elastic IP for database server
resource "aws_eip" "djsworld-aws-ngw-id" {
  instance = aws_instance.db-server.id
  vpc      = true
}

#NAT Gateway
resource "aws_nat_gateway" "aws-ngw" {
  allocation_id = aws_eip.djsworld-aws-ngw-id.id
  subnet_id     = aws_subnet.public-subnet.id

  tags = {
    Name = "NAT Gateway"
  }
}

#Routing Table Association to connect the Private Custom Subnet with the Routing Table
resource "aws_route_table" "private-rt" {
  vpc_id = aws_vpc.djsworld-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.aws-ngw.id
  }

  tags = {
    Name = "Private RT"
  }
}

#Routing Table Association to connect the Private Custom Subnet with the Routing Table
resource "aws_route_table_association" "private-rt-asso" {
  subnet_id      = aws_subnet.private-subnet.id
  route_table_id = aws_route_table.private-rt.id
}
