# SSH Key Pair
resource "aws_key_pair" "deployer" {
  key_name   = "wanderlust-key"
  public_key = var.public_key
}

# Bastion Host (public subnet - for SSH access)
resource "aws_instance" "bastion" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  key_name               = aws_key_pair.deployer.key_name
  subnet_id              = aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.public_sg.id]

  tags = {
    Name = "wanderlust-bastion"
  }

  root_block_device {
    volume_size = 20
    volume_type = "gp3"
  }
}

# Frontend EC2 (public subnet)
resource "aws_instance" "frontend" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  key_name               = aws_key_pair.deployer.key_name
  subnet_id              = aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.public_sg.id]

  tags = {
    Name = "wanderlust-frontend"
  }

  root_block_device {
    volume_size = 20
    volume_type = "gp3"
  }
}

# Backend EC2 (private subnet)
resource "aws_instance" "backend" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  key_name               = aws_key_pair.deployer.key_name
  subnet_id              = aws_subnet.private_subnet.id
  vpc_security_group_ids = [aws_security_group.private_sg.id]

  tags = {
    Name = "wanderlust-backend"
  }

  root_block_device {
    volume_size = 20
    volume_type = "gp3"
  }
}