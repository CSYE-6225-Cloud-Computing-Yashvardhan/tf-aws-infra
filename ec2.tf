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

  user_data = <<-EOF
              #!/bin/bash
              cd /home/csye6225/webapp/
              touch .env
              echo "DB_HOST=${element(split(":", aws_db_instance.mydb.endpoint), 0)}" >> /home/csye6225/webapp/.env
              echo "DB_USER=${aws_db_instance.mydb.username}" >> /home/csye6225/webapp/.env
              echo "DB_PASSWORD=${aws_db_instance.mydb.password}" >> /home/csye6225/webapp/.env
              echo "DB_NAME=${aws_db_instance.mydb.db_name}" >> /home/csye6225/webapp/.env
              echo "DB_PORT=3306" >> /home/csye6225/webapp/.env
              echo "PORT=3000" >> /home/csye6225/webapp/.env
              sudo systemctl enable webapp.service
              sudo systemctl status webapp.service
              sudo systemctl start webapp.service
              webappStarted=$?
              if [ $webappStarted -eq 0 ]; then 
                  echo "Success - webapp running."
              else
                  echo "Failed - webapp not running."
              fi
              EOF

  tags = {
    Name = "webapp-${formatdate("YYYY_MM_DD_hh_mm_ss", timestamp())}"
  }
}
