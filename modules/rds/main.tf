resource "aws_db_subnet_group" "db-subnet" {
  name       = "db_subnet_group"
  subnet_ids = var.subnet_ids
}

resource "aws_security_group" "allow_db" {
  name        = "permite_conexao_rds"
  description = "Grupo de seguranca para permitir conexao ao db"
  vpc_id      = var.vpc_id

  ingress {
    description = "Porta de conexao ao Postgres"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = var.vpc_cidr_block # [aws_vpc.dev-vpc.cidr_block] # aws_vpc.dev-vpc.cidr_blocks
  }

  tags = {
    Name = var.tag_sufix_name
  }
}

resource "aws_db_instance" "postgres" {
  allocated_storage = 10 # Espaço em disco em GB!
  identifier        = var.db_identifier #"banquinho"
  db_name           = "mydb"
  engine            = "postgres"
  engine_version    = "12.9"
  instance_class    = "db.t3.micro"
  username          = var.db_username # "username" # Nome do usuário "master"
  password          = var.db_password # "password" # Senha do usuário master
  port              = 5432
  skip_final_snapshot    = true
  db_subnet_group_name   = aws_db_subnet_group.db-subnet.name
  vpc_security_group_ids = [aws_security_group.allow_db.id]
  
  depends_on = [
    aws_security_group.allow_db,
    aws_db_subnet_group.db-subnet
  ]
}
