# ====================== RDS ======================
resource "aws_db_subnet_group" "main" {
  name       = "${var.app_name}-db-subnet"
  subnet_ids = aws_subnet.public[*].id
}

resource "aws_db_instance" "main" {
  identifier             = "${var.app_name}-postgres"
  engine                 = "postgres"
  engine_version         = "16"
  instance_class         = "db.t3.micro"
  allocated_storage      = 20
  username               = "postgres"
  db_name                = "nairatransfer"
  password               = "ChangeMe123!"
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