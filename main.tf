
#Define provider and region
provider "aws" {
  region = "us-east-1"
}

#Define provider and terraform versions
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

## VPC 

resource "aws_vpc" "web_server_vpc" {
  cidr_block           = "10.10.0.0/16"
  enable_dns_hostnames = true
  tags = {
    name = "web_server_web"
  }
}

## private subnet

resource "aws_subnet" "private_subnet" {
  cidr_block        = "10.10.1.0/24"
  vpc_id            = aws_vpc.web_server_vpc.id
  availability_zone = "us-east-1a"

  tags = {
    "Name" = "Private Subnet"
  }
}

## public subnet

resource "aws_subnet" "public_subnet" {
  cidr_block        = "10.10.2.0/24"
  vpc_id            = aws_vpc.web_server_vpc.id
  availability_zone = "us-east-1a"

  tags = {
    "Name" = "Public Subnet"
  }
}

## Internet Gateway

resource "aws_internet_gateway" "web_server_ig" {
  vpc_id = aws_vpc.web_server_vpc.id
  tags = {
    "Name" = "web_server_internet_gateway"
  }
}

## ElIP 

resource "aws_eip" "aws_eip" {
  depends_on = [
    aws_internet_gateway.web_server_ig
  ]
} 

## NAT Gateway

resource "aws_nat_gateway" "web_server_ng" {
  allocation_id = aws_eip.aws_eip.id
  subnet_id     = aws_subnet.public_subnet.id
 
}
 
  

## Route Table 

resource "aws_route_table" "web_server_rt" {
  vpc_id = aws_vpc.web_server_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.web_server_ig.id
  }
  tags = {
    "Name" = "Public Route Table"
  }
}

## Route Table 
resource "aws_route_table_association" "web_server_ass" {
  route_table_id = aws_route_table.web_server_rt.id
  subnet_id      = aws_subnet.public_subnet.id

}

resource "aws_security_group" "web_server_sg" {
  name        = "web_server_sg"
  description = "Allow 80 and 22 ports into web server"
  vpc_id      = aws_vpc.web_server_vpc.id



## HTTP port rule
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ## SSH port rule
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

tags = {
    Name = "web_server_sg"
  }
}


resource "aws_instance" "app_server" {
  ami = "ami-0b5eea76982371e91"


  instance_type = "t2.micro"

  subnet_id = aws_subnet.private_subnet.id

  associate_public_ip_address = true

  security_groups = [aws_security_group.web_server_sg.id]

  user_data = file("userdata")

  tags = {

    Name = "app server"

  }

}


## DEV_SERVER 



## private subnet

resource "aws_subnet" "private2_subnet" {
  cidr_block        = "10.10.3.0/24"
  vpc_id            = aws_vpc.web_server_vpc.id
  availability_zone = "us-east-1b"

  tags = {
    "Name" = "Private2 Subnet"
  }
}

## public subnet

resource "aws_subnet" "public2_subnet" {
  cidr_block        = "10.10.4.0/24"
  vpc_id            = aws_vpc.web_server_vpc.id
  availability_zone = "us-east-1b"

  tags = {
    "Name" = "Public2 Subnet"
  }
}

## Internet Gateway

## ElIP 

resource "aws_eip" "aws_eip2" {
  depends_on = [
    aws_internet_gateway.web_server_ig
  ]
} 

## NAT Gateway

resource "aws_nat_gateway" "web_server_ng2" {
  allocation_id = aws_eip.aws_eip2.id
  subnet_id     = aws_subnet.public2_subnet.id
 
}
 
  

## Route Table 

resource "aws_route_table" "web_server_rt2" {
  vpc_id = aws_vpc.web_server_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.web_server_ig.id
  }
  tags = {
    "Name" = "Public Route Table2"
  }
}

## Route Table 
resource "aws_route_table_association" "web_server_ass2" {
  route_table_id = aws_route_table.web_server_rt2.id
  subnet_id      = aws_subnet.private2_subnet.id

}

resource "aws_security_group" "web_server_sg2" {
  name        = "web_server_sg2"
  description = "Allow 80 and 22 ports into web server"
  vpc_id      = aws_vpc.web_server_vpc.id



## HTTP port rule
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ## SSH port rule
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

tags = {
    Name = "web_server_sg"
  }
}


resource "aws_instance" "dev_server" {
  ami = "ami-0b5eea76982371e91"


  instance_type = "t2.micro"

  subnet_id = aws_subnet.private2_subnet.id

  associate_public_ip_address = true

  security_groups = [aws_security_group.web_server_sg2.id]

  user_data = file("userdata2")

  tags = {

    Name = "dev server"

  }

}

## WEB SERVER

## private subnet

resource "aws_subnet" "private3_subnet" {
  cidr_block        = "10.10.5.0/24"
  vpc_id            = aws_vpc.web_server_vpc.id
  availability_zone = "us-east-1c"

  tags = {
    "Name" = "Private3 Subnet"
  }
}

## public subnet

resource "aws_subnet" "public3_subnet" {
  cidr_block        = "10.10.6.0/24"
  vpc_id            = aws_vpc.web_server_vpc.id
  availability_zone = "us-east-1c"

  tags = {
    "Name" = "Public2 Subnet"
  }
}

## Internet Gateway

## ElIP 

resource "aws_eip" "aws_eip3" {
  depends_on = [
    aws_internet_gateway.web_server_ig
  ]
} 

## NAT Gateway

resource "aws_nat_gateway" "web_server_ng3" {
  allocation_id = aws_eip.aws_eip3.id
  subnet_id     = aws_subnet.private3_subnet.id
 
}
 
  

## Route Table 

resource "aws_route_table" "web_server_rt3" {
  vpc_id = aws_vpc.web_server_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.web_server_ig.id
  }
  tags = {
    "Name" = "Public Route Table3"
  }
}

## Route Table 
resource "aws_route_table_association" "web_server_ass3" {
  route_table_id = aws_route_table.web_server_rt3.id
  subnet_id      = aws_subnet.private3_subnet.id

}

resource "aws_security_group" "web_server_sg3" {
  name        = "web_server_sg3"
  description = "Allow 80 and 22 ports into web server"
  vpc_id      = aws_vpc.web_server_vpc.id



## HTTP port rule
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ## SSH port rule
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

tags = {
    Name = "web_server_sg"
  }
}


resource "aws_instance" "web_server" {
  ami = "ami-0b5eea76982371e91"


  instance_type = "t2.micro"

  subnet_id = aws_subnet.private2_subnet.id

  associate_public_ip_address = true

  security_groups = [aws_security_group.web_server_sg2.id]

  user_data = file("userdata3")

  tags = {

    Name = "web server"

  }

}

## Public Route Table