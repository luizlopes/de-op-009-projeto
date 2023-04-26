output "db_name" {
  value = aws_db_instance.postgres.db_name
}

output "address" {
  value = aws_db_instance.postgres.address
}

output "username" {
  value = aws_db_instance.postgres.username
}

output "password" {
  value = aws_db_instance.postgres.password
}

output "database_port" {
  value = aws_db_instance.postgres.port
}
