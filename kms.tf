resource "aws_kms_key" "ec2_key" {
  description             = "KMS key for EC2 volume encryption"
  enable_key_rotation     = true
  deletion_window_in_days = 7
  policy                  = <<EOF
{
    "Id": "ec2-kms-policy",
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "Allow access for Root",
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::${var.account_id}:root"
            },
            "Action": "kms:*",
            "Resource": "*"
        },
        {
            "Sid": "Allow use of the key",
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::${var.account_id}:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling"
            },
            "Action": [
                "kms:Encrypt",
                "kms:Decrypt",
                "kms:ReEncrypt*",
                "kms:GenerateDataKey*",
                "kms:DescribeKey",
                "kms:CreateGrant",
                "kms:ListGrants",
                "kms:RevokeGrant"
            ],
            "Resource": "*"
        }
    ]
}

EOF
}

resource "aws_kms_key" "rds_key" {
  description             = "KMS key for RDS encryption"
  enable_key_rotation     = true
  deletion_window_in_days = 7
  policy                  = <<EOF
{
    "Id": "rds-kms-policy",
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "Allow access for Root",
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::${var.account_id}:root"
            },
            "Action": "kms:*",
            "Resource": "*"
        },
                {
            "Sid": "Allow use of the key",
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::${var.account_id}:role/aws-service-role/rds.amazonaws.com/AWSServiceRoleForRDS"
            },
            "Action": [
                "kms:Encrypt",
                "kms:Decrypt",
                "kms:ReEncrypt*",
                "kms:GenerateDataKey*",
                "kms:DescribeKey",
                "kms:CreateGrant",
                "kms:ListGrants",
                "kms:RevokeGrant"
            ],
            "Resource": "*"
        },
        {
            "Sid": "Allow use of the key",
            "Effect": "Allow",
            "Principal": {
                "AWS": "${aws_iam_role.ec2_access_role.arn}"
            },
            "Action": [
                "kms:Encrypt",
                "kms:Decrypt",
                "kms:ReEncrypt*"
            ],
            "Resource": "*"
        }
    ]
}
EOF

}

resource "aws_kms_key" "s3_key" {
  description             = "KMS key for S3 encryption"
  enable_key_rotation     = true
  deletion_window_in_days = 7
  policy                  = <<EOF
{
    "Id": "s3-kms-policy",
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "Allow access for Root",
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::${var.account_id}:root"
            },
            "Action": "kms:*",
            "Resource": "*"
        },
        {
            "Sid": "Allow S3 Encryption",
            "Effect": "Allow",
            "Principal": {
                "AWS": "${aws_iam_role.ec2_access_role.arn}"
            },
            "Action": [
                "kms:Encrypt",
                "kms:Decrypt",
                "kms:ReEncrypt*",
                "kms:GenerateDataKey*",
                "kms:DescribeKey"
            ],
            "Resource": "*"
        },
        {
            "Sid": "Allow Grant Creation for S3 Resources",
            "Effect": "Allow",
            "Principal": {
                "AWS": "${aws_iam_role.ec2_access_role.arn}"
            },
            "Action": [
                "kms:CreateGrant",
                "kms:ListGrants",
                "kms:RevokeGrant"
            ],
            "Resource": "*",
            "Condition": {
                "Bool": {
                    "kms:GrantIsForAWSResource": "true"
                }
            }
        }
    ]
}
EOF

}

resource "aws_kms_key" "secrets_manager_key" {
  description             = "KMS key for general-purpose secret encryption"
  enable_key_rotation     = true
  deletion_window_in_days = 7
  policy                  = <<EOF
{
    "Id": "general-purpose-kms-policy",
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "Allow access for Root",
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::${var.account_id}:root"
            },
            "Action": "kms:*",
            "Resource": "*"
        },
        {
            "Sid": "Allow use of the key for lambda role",
            "Effect": "Allow",
            "Principal": {
                "AWS": "${aws_iam_role.lambda_execution_role.arn}"
            },
            "Action": [
                "kms:Encrypt",
                "kms:Decrypt",
                "kms:ReEncrypt*",
                "kms:GenerateDataKey*",
                "kms:DescribeKey"
            ],
            "Resource": "*"
        },
        {
            "Sid": "Allow use of the key for EC2 Role",
            "Effect": "Allow",
            "Principal": {
                "AWS": "${aws_iam_role.ec2_access_role.arn}"
            },
            "Action": [
                "kms:Encrypt",
                "kms:Decrypt",
                "kms:ReEncrypt*",
                "kms:GenerateDataKey*",
                "kms:DescribeKey"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}

resource "random_id" "secret_suffix" {
  byte_length = 4
}

resource "aws_secretsmanager_secret" "db_password" {
  name       = "db-password-secret-${random_id.secret_suffix.hex}"
  kms_key_id = aws_kms_key.secrets_manager_key.arn
}

resource "aws_secretsmanager_secret_version" "db_password_version" {
  secret_id = aws_secretsmanager_secret.db_password.id
  secret_string = jsonencode({
    password = aws_db_instance.mydb.password
  })
}

resource "aws_secretsmanager_secret" "email_service" {
  name       = "email-service-secret-${random_id.secret_suffix.hex}"
  kms_key_id = aws_kms_key.secrets_manager_key.arn
}

resource "aws_secretsmanager_secret_version" "email_service_version" {
  secret_id = aws_secretsmanager_secret.email_service.id
  secret_string = jsonencode({
    api_key = var.mailgun_api_key
  })
}

output "db_password_name" {
  value = aws_secretsmanager_secret.db_password.name
}
