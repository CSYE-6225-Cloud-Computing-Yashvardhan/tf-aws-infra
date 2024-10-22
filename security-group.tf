resource "aws_security_group" "app_sg" {
  vpc_id      = aws_vpc.main.id
  name        = "app-security-group"
  description = "Allow TLS inbound traffic"

  ingress {
    from_port   = var.ssh_port
    to_port     = var.ssh_port
    protocol    = var.protocol
    cidr_blocks = var.ssh_cidr
    description = "Allow SSH traffic from anywhere"
  }

  ingress {
    from_port   = var.http_port
    to_port     = var.http_port
    protocol    = var.protocol
    cidr_blocks = var.http_cidr
    description = "Allow HTTP traffic from anywhere"
  }

  ingress {
    from_port   = var.https_port
    to_port     = var.https_port
    protocol    = var.protocol
    cidr_blocks = var.https_cidr
    description = "Allow HTTPS traffic from anywhere"
  }

  ingress {
    from_port   = var.custom_port
    to_port     = var.custom_port
    protocol    = var.protocol
    cidr_blocks = var.custom_cidr
    description = "Allow Custom traffic for the application"
  }

  egress {
    from_port   = var.outbound_port
    to_port     = var.outbound_port
    protocol    = var.outbound_protocol
    cidr_blocks = var.outbound_cidr
    description = "Allow Outbound traffic for the application"
  }

  tags = {
    Name = "app-sg"
  }
}

resource "aws_security_group" "db_sg" {
  vpc_id      = aws_vpc.main.id
  name        = "db-security-group"
  description = "Allow MySQL inbound traffic from the application security group"

  ingress {
    from_port       = var.db_port
    to_port         = var.db_port
    protocol        = var.protocol
    security_groups = [aws_security_group.app_sg.id]
    description     = "Allow MySQL traffic from the app security group"
  }

  egress {
    from_port   = var.outbound_port
    to_port     = var.outbound_port
    protocol    = var.outbound_protocol
    cidr_blocks = var.outbound_cidr
    description = "Allow all outbound traffic"
  }

  tags = {
    Name = "db-sg"
  }
}
