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
  region = var.aws_region
  
  default_tags {
    tags = {
      Project     = var.project_name
      Environment = "learning"
      Phase       = "1"
      ManagedBy   = "Terraform"
      Owner       = "quantum-security-research"
    }
  }
}

# Variables
variable "aws_region" {
  description = "AWS Region"
  type        = string
  default     = "eu-west-3"
}

variable "my_ip" {
  description = "Your public IP for SSH access"
  type        = string
}

variable "key_name" {
  description = "SSH key pair name"
  type        = string
  default     = "quantum-key-phase1"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.small"
}

variable "project_name" {
  description = "Project name for tagging"
  type        = string
  default     = "quantum-phase1"
}

# VPC (using default VPC for simplicity in Phase 1)
data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# Security Group
resource "aws_security_group" "learning" {
  name        = "${var.project_name}-sg"
  description = "Security group for Phase 1 learning instance"
  vpc_id      = data.aws_vpc.default.id

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

  # SPIRE Server (for future Week 2)
  ingress {
    description = "SPIRE Server"
    from_port   = 8081
    to_port     = 8081
    protocol    = "tcp"
    cidr_blocks = ["${var.my_ip}/32"]
  }

  # All outbound
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-sg"
  }
}

# Latest Ubuntu 22.04 AMI
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# EC2 Instance
resource "aws_instance" "learning" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  key_name      = var.key_name

  vpc_security_group_ids = [aws_security_group.learning.id]
  subnet_id              = data.aws_subnets.default.ids[0]

  root_block_device {
    volume_size           = 50  # GB - enough for labs
    volume_type           = "gp3"
    delete_on_termination = true
    encrypted             = true

    tags = {
      Name = "${var.project_name}-root"
    }
  }

  user_data = templatefile("${path.module}/user-data.sh", {
    project_name = var.project_name
  })

  # Enable detailed monitoring
  monitoring = true

  # Enable termination protection (optional, remove for easy cleanup)
  # disable_api_termination = true

  tags = {
    Name = "${var.project_name}-instance"
    Week = "1-3"
  }
}

# Elastic IP for stable IP address
resource "aws_eip" "learning" {
  instance = aws_instance.learning.id
  domain   = "vpc"

  tags = {
    Name = "${var.project_name}-eip"
  }
}

# CloudWatch Alarm for high CPU (optional monitoring)
resource "aws_cloudwatch_metric_alarm" "high_cpu" {
  alarm_name          = "${var.project_name}-high-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "300"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "This metric monitors ec2 cpu utilization"

  dimensions = {
    InstanceId = aws_instance.learning.id
  }

  alarm_actions = []  # Add SNS topic ARN for notifications
}

# Outputs
output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.learning.id
}

output "public_ip" {
  description = "Public IP address (Elastic IP)"
  value       = aws_eip.learning.public_ip
}

output "private_ip" {
  description = "Private IP address"
  value       = aws_instance.learning.private_ip
}

output "ssh_command" {
  description = "SSH command to connect"
  value       = "ssh -i ~/.ssh/${var.key_name}.pem ubuntu@${aws_eip.learning.public_ip}"
}

output "instance_info" {
  description = "Instance information"
  value = {
    id          = aws_instance.learning.id
    type        = aws_instance.learning.instance_type
    public_ip   = aws_eip.learning.public_ip
    private_ip  = aws_instance.learning.private_ip
    az          = aws_instance.learning.availability_zone
  }
}

output "next_steps" {
  description = "What to do next"
  value = <<-EOT
  
  ✅ Infrastructure deployed successfully!
  
  📋 Next steps:
  
  1. SSH into instance:
     ssh -i ~/.ssh/${var.key_name}.pem ubuntu@${aws_eip.learning.public_ip}
  
  2. Wait for user-data to complete:
     tail -f /var/log/cloud-init-output.log
  
  3. Run setup script:
     chmod +x ~/setup-phase1.sh
     ./setup-phase1.sh
  
  4. Clone your project:
     cd ~/workspace
     git clone <your-repo-url> quantum-security-project
  
  5. Start Lab 1.1:
     cd quantum-security-project/labs/openssl
     cat LAB-1.1-Certificates.md
  
  💰 Costs: ~€15/month for t3.small
  
  📚 Documentation: docs/PHASE1_START.md
  
  EOT
}
