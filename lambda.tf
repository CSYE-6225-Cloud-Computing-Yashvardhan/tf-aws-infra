resource "aws_lambda_function" "email_verification_lambda" {
  filename      = "path/to/your/lambda.zip"
  function_name = "email_verification_lambda"
  role          = aws_iam_role.lambda_execution_role.arn
  handler       = "index.handler"
  runtime       = "nodejs20.x"
  timeout       = 15

  vpc_config {
    subnet_ids         = aws_subnet.private[*].id
    security_group_ids = [aws_security_group.lambda_sg.id]
  }

  environment {
    variables = {
      DB_HOST     = element(split(":", aws_db_instance.mydb.endpoint), 0)
      DB_USER     = aws_db_instance.mydb.username
      DB_PASSWORD = aws_db_instance.mydb.password
      DB_NAME     = aws_db_instance.mydb.db_name
      DB_PORT     = "3306"
    }
  }

  tags = {
    Name = "email-verification-lambda"
  }
}

resource "aws_sns_topic" "email_verification" {
  name = "email_verification_sns_topic"
}

resource "aws_lambda_permission" "allow_sns" {
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.email_verification_lambda.arn
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.email_verification.arn
}
