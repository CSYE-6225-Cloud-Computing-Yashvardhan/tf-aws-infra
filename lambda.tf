resource "aws_lambda_function" "email_verification_lambda" {
  filename      = "F:/Classwork/CSYE-6225 Cloud/Cloud Native App/serverless/lambda.zip"
  function_name = "email_verification_lambda"
  role          = aws_iam_role.lambda_execution_role.arn
  handler       = "index.handler"
  runtime       = "nodejs18.x"
  timeout       = 30

  vpc_config {
    subnet_ids         = aws_subnet.private[*].id
    security_group_ids = [aws_security_group.lambda_sg.id]
  }

  environment {
    variables = {
      DB_HOST                 = element(split(":", aws_db_instance.mydb.endpoint), 0)
      DB_USER                 = aws_db_instance.mydb.username
      DB_PASSWORD             = aws_db_instance.mydb.password
      DB_NAME                 = aws_db_instance.mydb.db_name
      DB_PORT                 = "3306"
      MAILGUN_API_KEY         = var.mailgun_api_key
      EMAIL_SERVICE_SECRET_ID = aws_secretsmanager_secret.email_service.name
    }
  }

  tags = {
    Name = "email-verification-lambda"
  }
}


resource "aws_sns_topic" "email_verification" {
  name = "email_verification_sns_topic"
}

resource "aws_sns_topic_subscription" "email_verification_subscription" {
  topic_arn = aws_sns_topic.email_verification.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.email_verification_lambda.arn
}

resource "aws_lambda_permission" "allow_sns" {
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.email_verification_lambda.arn
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.email_verification.arn
}
