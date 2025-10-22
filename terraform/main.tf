provider "aws" {
  region = "us-east-1"
}

# 1️⃣ VPC
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  tags = { Name = "ci-cd-vpc" }
}

# 2️⃣ Public Subnet
resource "aws_subnet" "public" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "ap-south-1a"
  map_public_ip_on_launch = true
  tags = { Name = "ci-cd-public-subnet" }
}

# 3️⃣ Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags   = { Name = "ci-cd-igw" }
}

# 4️⃣ Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  tags   = { Name = "ci-cd-public-rt" }
}

# Route to Internet Gateway
resource "aws_route" "internet_access" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

# Associate route table with public subnet
resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# 5️⃣ Security Group
resource "aws_security_group" "jenkins_sg" {
  name        = "jenkins-sg"
  description = "Allow SSH and Jenkins"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
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

# 6️⃣ EC2 Instance
resource "aws_instance" "jenkins" {
  ami           = "ami-0c2b8ca1dad447f8a"
  instance_type = "t2.medium"
  subnet_id     = aws_subnet.public.id
  security_groups = [aws_security_group.jenkins_sg.name]
  key_name      = "your-keypair"
  tags = { Name = "jenkins-server" }
}

# 7️⃣ Output public IP
output "jenkins_public_ip" {
  value = aws_instance.jenkins.public_ip
}
