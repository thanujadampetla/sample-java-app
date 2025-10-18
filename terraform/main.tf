provider "aws" {
  region = "us-east-1"
}

# VPC
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  tags = { Name = "ci-cd-vpc" }
}

resource "aws_subnet" "public" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(aws_vpc.main.cidr_block, 8, 1)
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true
  tags = { Name = "ci-cd-subnet" }
}


# Security Group
resource "aws_security_group" "jenkins_sg" {
  vpc_id = aws_vpc.main.id
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = { Name = "jenkins-sg" }
}

# Use latest Amazon Linux 2 AMI
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

resource "aws_instance" "jenkins" {
  ami             = data.aws_ami.amazon_linux.id
  instance_type   = "t3.micro"
  subnet_id       = aws_subnet.public.id
  associate_public_ip_address = true

  # Use VPC security group IDs, not names
  vpc_security_group_ids = [aws_security_group.jenkins_sg.id]

  key_name        = "vle8"
  tags = { Name = "jenkins-server" }
}


# Output public IP
output "jenkins_public_ip" {
  value = aws_instance.jenkins.public_ip
}
