resource "aws_db_instance" "default" {
  allocated_storage       = 10
  db_name                 = "mydb"
  identifier              = "rds-test"
  engine                  = "mysql"
  engine_version          = "8.0"
  instance_class          = "db.t3.micro"
  username                = "admin"
  password                = "Cloud123"
  db_subnet_group_name    = aws_db_subnet_group.sub-grp.id
  parameter_group_name    = "default.mysql8.0"

  # Enable backups and retention
  backup_retention_period  = 1   # Retain backups for 7 days
  backup_window            = "02:00-03:00" # Daily backup window (UTC)


  # Enable performance insights
  # performance_insights_enabled          = true
  # performance_insights_retention_period = 7  # Retain insights for 7 days

  # Maintenance window
  maintenance_window = "sun:04:00-sun:05:00"  # Maintenance every Sunday (UTC)

  # Enable deletion protection (to prevent accidental deletion)
  deletion_protection = false

  # Skip final snapshot
  skip_final_snapshot = true
  depends_on = [ aws_db_subnet_group.sub-grp ]
}

data "aws_subnet" "subnet-1" {
  filter {
    name   = "tag:Name"
    values = ["subnet-1"]
  }
}

data "aws_subnet" "subnet-2" {
  filter {
    name   = "tag:Name"
    values = ["subnet-2"]
  }
}

resource "aws_db_subnet_group" "sub-grp" { 
    name = "rds-subnet" 
    subnet_ids = [data.aws_subnet.subnet-1.id, data.aws_subnet.subnet-2.id] 
    depends_on = [ aws_subnet.subnet-1, aws_subnet.subnet-2 ] 
    tags = { 
        Name = "My DB subnet group" 
    } 
}