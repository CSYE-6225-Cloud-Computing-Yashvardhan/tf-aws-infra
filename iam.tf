resource "aws_iam_role" "ec2_access_role" {
  name = "ec2_access_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Terraform = "true"
  }
}

resource "aws_iam_policy" "webapp_s3_access_policy" {
  name        = "webapp_s3_access_policy"
  description = "Policy to allow access to S3 bucket"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ],
        "Effect" : "Allow",
        "Resource" : [
          "arn:aws:s3:::${aws_s3_bucket.webapp_bucket.bucket}",
          "arn:aws:s3:::${aws_s3_bucket.webapp_bucket.bucket}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_instance_profile" "webapp_s3_access_instance_profile" {
  name = "webapp_s3_access_instance_profile"
  role = aws_iam_role.ec2_access_role.name

  tags = {
    Terraform = "true"
  }
}

resource "aws_iam_role_policy_attachment" "s3_access_role_policy_attachment" {
  policy_arn = aws_iam_policy.webapp_s3_access_policy.arn
  role       = aws_iam_role.ec2_access_role.name
}

resource "aws_iam_role_policy_attachment" "webapp_cloudwatch_policy" {
  role       = aws_iam_role.ec2_access_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_iam_role" "lambda_execution_role" {
  name = "lambda_execution_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_vpc_access" {
  role       = aws_iam_role.lambda_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}


resource "aws_iam_policy" "sns_publish_policy" {
  name        = "sns_publish_policy"
  description = "Policy to allow Lambda to publish to the email verification SNS topic"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "sns:Publish"
        Resource = aws_sns_topic.email_verification.arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "sns_publish" {
  role       = aws_iam_role.lambda_execution_role.name
  policy_arn = aws_iam_policy.sns_publish_policy.arn
}

resource "aws_iam_role_policy_attachment" "ec2_sns_publish_policy_attachment" {
  role       = aws_iam_role.ec2_access_role.name
  policy_arn = aws_iam_policy.sns_publish_policy.arn
}

resource "aws_iam_role_policy" "lambda_secrets_manager_access" {
  name   = "LambdaSecretsManagerAccessPolicy"
  role   = aws_iam_role.lambda_execution_role.name
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "secretsmanager:GetSecretValue"
            ],
            "Resource": "${aws_secretsmanager_secret.email_service.arn}"
        },
        {
            "Effect": "Allow",
            "Action": [
                "kms:Decrypt"
            ],
            "Resource": "${aws_kms_key.secrets_manager_key.arn}"
        }
    ]
}
EOF
}

resource "aws_iam_policy" "secrets_manager_access_policy" {
  name        = "ec2_secrets_manager_access_policy"
  description = "Policy to allow EC2 access to Secrets Manager"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ],
        "Resource" : "${aws_secretsmanager_secret.db_password.arn}"
      }
    ]
  })
}

resource "aws_iam_role_policy" "ec2_secrets_manager_access" {
  name   = "EC2_SecretsManagerAccessPolicy"
  role   = aws_iam_role.ec2_access_role.name
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "secretsmanager:GetSecretValue"
            ],
            "Resource": "${aws_secretsmanager_secret.db_password.arn}"
        },
        {
            "Effect": "Allow",
            "Action": [
                "kms:Decrypt"
            ],
            "Resource": "${aws_kms_key.ec2_key.arn}"
        },
        {
            "Effect": "Allow",
            "Action": [
                "kms:Decrypt"
            ],
            "Resource": "${aws_kms_key.secrets_manager_key.arn}"
        }
    ]
}
EOF
}



