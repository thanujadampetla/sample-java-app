provider "aws" {
  region = "ap-south-1"
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  tags = { Name = "ci-cd-vpc" }
}

resource "aws_subnet" "public" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "ap-south-1a"
  map_public_ip_on_launch = true
  tags = { Name = "ci-cd-subnet" }
}

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

resource "aws_instance" "jenkins" {
  ami           = "ami-0c2b8ca1dad447f8a"
  instance_type = "t2.medium"
  subnet_id     = aws_subnet.public.id
  security_groups = [aws_security_group.jenkins_sg.name]
  key_name      = "your-keypair"
  tags = { Name = "jenkins-server" }
}

output "jenkins_public_ip" {
  value = aws_instance.jenkins.public_ip
}
