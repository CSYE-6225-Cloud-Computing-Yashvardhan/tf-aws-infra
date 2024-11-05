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
    from_port       = var.custom_port
    to_port         = var.custom_port
    protocol        = var.protocol
    security_groups = [aws_security_group.lb_sg.id]
    description     = "Allow Custom traffic for the application"
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

resource "aws_security_group" "lb_sg" {
  vpc_id      = aws_vpc.main.id
  name        = "load-balancer-security-group"
  description = "Allow HTTP and HTTPS traffic to load balancer"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "load-balancer-sg"
  }
}

