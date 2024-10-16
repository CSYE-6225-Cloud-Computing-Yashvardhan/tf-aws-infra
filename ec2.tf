resource "aws_instance" "web_app" {
  ami                         = "ami-088c15838c234ce29"
  instance_type               = "t2.small"
  subnet_id                   = aws_subnet.public[0].id
  security_groups             = [aws_security_group.app_sg.id]
  associate_public_ip_address = true
  key_name                    = "aws-dev"
  disable_api_termination     = false

  root_block_device {
    volume_size           = 25
    volume_type           = "gp2"
    delete_on_termination = true
  }

  tags = {
    Name = "webapp-${formatdate("YYYY_MM_DD_hh_mm_ss", timestamp())}"
  }
}
