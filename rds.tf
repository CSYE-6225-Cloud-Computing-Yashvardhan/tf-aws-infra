resource "aws_db_instance" "mydb" {
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = "db.t3.micro"
  allocated_storage      = 20
  identifier             = "csye6225"
  db_name                = "csye6225"
  username               = "csye6225"
  password               = "csye6225"
  db_subnet_group_name   = aws_db_subnet_group.mydb_subnet_group.name
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  multi_az               = false
  publicly_accessible    = false
  parameter_group_name   = aws_db_parameter_group.mydb_parameters.name
  skip_final_snapshot    = true

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
  family = "mysql8.0"

  tags = {
    Name = "mydb-parameter-group"
  }
}
