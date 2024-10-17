resource "aws_instance" "web_app" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public[0].id
  security_groups             = [aws_security_group.app_sg.id]
  associate_public_ip_address = var.assoc_public_ip
  key_name                    = var.aws_configured_key_name
  disable_api_termination     = var.disable_api_term

  root_block_device {
    volume_size           = var.vol_size
    volume_type           = var.vol_type
    delete_on_termination = var.delete_on_term
  }

  tags = {
    Name = "webapp-${formatdate("YYYY_MM_DD_hh_mm_ss", timestamp())}"
  }
}
