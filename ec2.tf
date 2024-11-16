/*resource "aws_instance" "web_app" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public[0].id
  security_groups             = [aws_security_group.app_sg.id]
  associate_public_ip_address = var.assoc_public_ip
  key_name                    = var.aws_configured_key_name
  disable_api_termination     = var.disable_api_term
  iam_instance_profile        = aws_iam_instance_profile.webapp_s3_access_instance_profile.name

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
              echo "AWS_S3_BUCKET_NAME=${aws_s3_bucket.webapp_bucket.bucket}" >> .env
              sudo systemctl enable webapp.service
              sudo systemctl status webapp.service
              sudo systemctl start webapp.service
              if [ $webappStarted -eq 0 ]; then 
                  echo "Success - webapp running."
              else
                  echo "Failed - webapp not running."
              fi
              sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -c file:/opt/cloudwatch-config.json -s
              cloudwatch=$?
              if [ $cloudwatch -eq 0 ]; then 
                  echo "Success - Cloudwatch running."
              else
                  echo "Failed - Cloudwatch not running."
              fi
              EOF

  tags = {
    Name = "webapp-${formatdate("YYYY_MM_DD_hh_mm_ss", timestamp())}"
  }
}*/

resource "aws_launch_template" "web_app_launch_template" {
  name                    = "csye6225_asg"
  image_id                = var.ami_id
  instance_type           = var.instance_type
  key_name                = var.aws_configured_key_name
  disable_api_termination = var.disable_api_term
  user_data = base64encode(<<-EOF
              #!/bin/bash
              cd /home/csye6225/webapp/
              touch .env
              echo "DB_HOST=${element(split(":", aws_db_instance.mydb.endpoint), 0)}" >> /home/csye6225/webapp/.env
              echo "DB_USER=${aws_db_instance.mydb.username}" >> /home/csye6225/webapp/.env
              echo "DB_PASSWORD=${aws_db_instance.mydb.password}" >> /home/csye6225/webapp/.env
              echo "DB_NAME=${aws_db_instance.mydb.db_name}" >> /home/csye6225/webapp/.env
              echo "DB_PORT=3306" >> /home/csye6225/webapp/.env
              echo "PORT=3000" >> /home/csye6225/webapp/.env
              echo "AWS_S3_BUCKET_NAME=${aws_s3_bucket.webapp_bucket.bucket}" >> .env
              echo "EMAIL_VERIFICATION_SNS_ARN=${aws_sns_topic.email_verification.arn}" >> .env
              sudo systemctl enable webapp.service
              sudo systemctl status webapp.service
              sudo systemctl start webapp.service
              if [ $webappStarted -eq 0 ]; then 
                  echo "Success - webapp running."
              else
                  echo "Failed - webapp not running."
              fi
              sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -c file:/opt/cloudwatch-config.json -s
              cloudwatch=$?
              if [ $cloudwatch -eq 0 ]; then 
                  echo "Success - Cloudwatch running."
              else
                  echo "Failed - Cloudwatch not running."
              fi
              EOF
  )

  block_device_mappings {
    device_name = "/dev/sda1"
    ebs {
      delete_on_termination = true
      volume_size           = 25
      volume_type           = "gp2"
    }
  }

  network_interfaces {
    associate_public_ip_address = var.assoc_public_ip
    security_groups             = [aws_security_group.app_sg.id]
  }
  iam_instance_profile {
    name = aws_iam_instance_profile.webapp_s3_access_instance_profile.name
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "webapp-auto-instance"
    }
  }
}
