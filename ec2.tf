resource "aws_instance" "web_app" {
  ami                         = "ami-088c15838c234ce29"
  instance_type               = "t2.small"
  subnet_id                   = aws_subnet.public[0].id
  security_groups             = [aws_security_group.app_sg.id]
  associate_public_ip_address = true

  root_block_device {
    volume_size           = 25
    volume_type           = "gp2"
    delete_on_termination = true
  }

  disable_api_termination = false
  key_name                = "aws-dev"

  tags = {
    Name = "webapp-${formatdate("YYYY_MM_DD_hh_mm_ss", timestamp())}"
  }
}
