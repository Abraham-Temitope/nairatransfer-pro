# ====================== RDS ======================
resource "aws_db_subnet_group" "main" {
  name       = "${var.app_name}-db-subnet-group"
  subnet_ids = aws_subnet.private[*].id
}

resource "aws_db_instance" "main" {
  identifier             = "${var.app_name}-postgres"
  engine                 = "postgres"
  engine_version         = "16"
  instance_class         = "db.t3.micro"
  allocated_storage      = 20
  username               = "postgres"
  db_name                = "nairatransfer"
  password               = jsondecode(aws_secretsmanager_secret_version.app.secret_string)["DB_PASSWORD"]
  skip_final_snapshot    = true
  publicly_accessible    = false
  vpc_security_group_ids = [aws_security_group.rds.id]
  db_subnet_group_name   = aws_db_subnet_group.main.name
  multi_az               = false

  tags = {
    Name        = "${var.app_name}-rds"
    Environment = var.environment
  }
}