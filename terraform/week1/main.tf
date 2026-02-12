terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "eu-west-1"  # Geneva proche
}

# Variables
variable "my_ip" {
  description = "Your public IP for SSH access (get with: curl ifconfig.me)"
  type        = string
}

variable "key_name" {
  description = "SSH key pair name in AWS"
  type        = string
  default     = "quantum-security-key"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.small"  # 2GB RAM, 2 vCPU, ~€15/mois
  # Alternative: "t2.micro" for Free Tier (1GB RAM, mais plus lent)
}

# VPC
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name    = "quantum-security-vpc"
    Project = "PostQuantum-Week1"
    Week    = "1"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "quantum-security-igw"
  }
}

# Public Subnet
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "eu-west-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "quantum-security-public"
  }
}

# Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "quantum-security-public-rt"
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# Security Group
resource "aws_security_group" "dev" {
  name        = "quantum-security-dev-sg"
  description = "Security group for dev workstation"
  vpc_id      = aws_vpc.main.id

  # SSH from your IP only
  ingress {
    description = "SSH from my IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.my_ip}/32"]
  }

  # HTTP for Nginx demos
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTPS for Nginx demos
  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # SPIRE Server API (for future Week 2 - within VPC)
  ingress {
    description = "SPIRE Server API"
    from_port   = 8081
    to_port     = 8081
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  # All outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "quantum-security-sg"
  }
}

# EC2 Instance
resource "aws_instance" "dev" {
  # Ubuntu 22.04 LTS AMI for eu-west-1
  # Vérifier dernière AMI: https://cloud-images.ubuntu.com/locator/ec2/
  ami           = "ami-0c38b837cd80f13bb"
  instance_type = var.instance_type

  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.dev.id]
  key_name               = var.key_name

  root_block_device {
    volume_size           = 30  # GB
    volume_type           = "gp3"
    delete_on_termination = true

    tags = {
      Name = "quantum-dev-root"
    }
  }

  # User data pour installation de base
  user_data = file("${path.module}/user-data.sh")

  tags = {
    Name    = "quantum-dev-week1"
    Project = "PostQuantum-Crypto"
    Week    = "1"
  }
}

# Elastic IP (IP publique fixe)
resource "aws_eip" "dev" {
  instance = aws_instance.dev.id
  domain   = "vpc"

  tags = {
    Name = "quantum-dev-eip"
  }
}

# Outputs
output "instance_id" {
  description = "ID de l'instance EC2"
  value       = aws_instance.dev.id
}

output "public_ip" {
  description = "IP publique de l'instance"
  value       = aws_eip.dev.public_ip
}

output "private_ip" {
  description = "IP privée de l'instance"
  value       = aws_instance.dev.private_ip
}

output "ssh_command" {
  description = "Commande SSH pour se connecter"
  value       = "ssh -i ~/.ssh/${var.key_name}.pem ubuntu@${aws_eip.dev.public_ip}"
}

output "instance_info" {
  description = "Informations complètes de l'instance"
  value = {
    id          = aws_instance.dev.id
    public_ip   = aws_eip.dev.public_ip
    private_ip  = aws_instance.dev.private_ip
    type        = aws_instance.dev.instance_type
    vpc_id      = aws_vpc.main.id
    subnet_id   = aws_subnet.public.id
  }
}

output "next_steps" {
  description = "Prochaines étapes"
  value = <<-EOT
  
  ✅ Infrastructure déployée avec succès!
  
  Prochaines étapes:
  
  1. Se connecter à l'instance:
     ssh -i ~/.ssh/${var.key_name}.pem ubuntu@${aws_eip.dev.public_ip}
  
  2. Vérifier que user-data est terminé:
     ls -la ~/user-data-complete
  
  3. Installer les outils complets:
     wget https://raw.githubusercontent.com/.../setup-aws-week1.sh
     chmod +x setup-aws-week1.sh
     ./setup-aws-week1.sh
  
  4. Redémarrer session:
     exit
     ssh -i ~/.ssh/${var.key_name}.pem ubuntu@${aws_eip.dev.public_ip}
  
  5. Cloner le projet et commencer Lab 1.1!
  
  Coût estimé: ~€15/mois (t3.small) ou €0 avec Free Tier (t2.micro)
  
  EOT
}
