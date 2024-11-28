resource "random_password" "rds_password" {
  length  = 16
  special = false
  upper   = true
  lower   = true
}
resource "aws_db_instance" "mydb" {
  engine                 = var.db_engine
  engine_version         = var.db_engine_ver
  instance_class         = var.db_instance_class
  allocated_storage      = var.db_storage
  identifier             = var.db_identifier
  db_name                = var.db_name
  username               = var.db_user
  password               = random_password.rds_password.result
  db_subnet_group_name   = aws_db_subnet_group.mydb_subnet_group.name
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  multi_az               = var.db_multi_az
  publicly_accessible    = var.db_pub_access
  parameter_group_name   = aws_db_parameter_group.mydb_parameters.name
  skip_final_snapshot    = var.db_skip_fi_snap
  storage_encrypted      = true
  kms_key_id             = aws_kms_key.rds_key.arn


  tags = {
    Name = "csye6225-db"
  }
}

resource "aws_db_subnet_group" "mydb_subnet_group" {
  name       = "mydb-subnet-group"
  subnet_ids = aws_subnet.private[*].id

  tags = {
    Name = "mydb-subnet-group"
  }
}

resource "aws_db_parameter_group" "mydb_parameters" {
  name   = "mydb-parameter-group"
  family = var.db_para_family

  tags = {
    Name = "mydb-parameter-group"
  }
}
