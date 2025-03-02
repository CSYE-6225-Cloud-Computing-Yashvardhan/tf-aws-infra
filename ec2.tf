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
              for i in {1..5}; do
                dbpass=$(aws secretsmanager get-secret-value \
                  --secret-id ${aws_secretsmanager_secret.db_password.arn} \
                  --region ${var.region} \
                  --query 'SecretString' \
                  --output text | jq -r '.password')
                
                if [ -n "$dbpass" ]; then
                  echo "Successfully retrieved DB password."
                  break
                fi
                
                echo "Retrying secret retrieval in 10 seconds..."
                sleep 10
              done

              if [ -z "$dbpass" ]; then
                echo "Failed to retrieve DB password from Secrets Manager."
              else
                echo "DB_PASSWORD=$dbpass" >> /home/csye6225/webapp/.env
              fi
              echo "DB_NAME=${aws_db_instance.mydb.db_name}" >> /home/csye6225/webapp/.env
              echo "DB_PORT=3306" >> /home/csye6225/webapp/.env
              echo "PORT=3000" >> /home/csye6225/webapp/.env
              echo "AWS_S3_BUCKET_NAME=${aws_s3_bucket.webapp_bucket.bucket}" >> .env
              echo "EMAIL_VERIFICATION_SNS_ARN=${aws_sns_topic.email_verification.arn}" >> .env
              echo "DOMAIN=${data.aws_route53_zone.domain.name}" >> .env
              echo "DB_SECRETS_NAME=${aws_secretsmanager_secret.db_password.name}" >> .env
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
      kms_key_id            = aws_kms_key.ec2_key.arn
      encrypted             = true
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
