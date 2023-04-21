terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

provider "aws" {
  profile    = "bootcamp" # Aqui vai o "profile" que você configurou as credenciais da AWS.
  region     = "us-east-1"
}

resource "aws_s3_bucket" "my_bucket" {
  bucket = "de-op-009-bucket-luiz"
  force_destroy = true

  tags = {
    Name = "bootcamp"
    Turma = "DE-OP-009-983"
  }
}

# Cria um documento para política do "lambda ser um lambda", assumir uma role.
# Pode ser utilizado também um objeto do tipo aws_s3_bucket_policy, como temos no 2 - s3 com website. 
# São duas formas de "fazer a mesma coisa". 
data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"] 
  }
}

# Crio uma role para o lambda. 
# Lembrando: uma role é um conjunto de permissões.
resource "aws_iam_role" "iam_for_lambda" {
  name               = "iam_para_o_lambda"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

# Crio uma permissão para o lambda poder criar log streams 
# e enviar logs para o cloudwatch
# resource "aws_iam_policy" "function_logging_policy" {
#   name   = "function-logging-policy"
#   policy = jsonencode({
#     "Version" : "2012-10-17",
#     "Statement" : [
#       {
#         Action : [
#           "logs:CreateLogStream",
#           "logs:PutLogEvents"
#         ],
#         Effect : "Allow",
#         Resource : "arn:aws:logs:*:*:*"
#       }
#     ]
#   })
# }

# Aqui eu adiciono mais uma policy à role do lambda. 
# Posso adicionar quantas forem necessárias
resource "aws_iam_role_policy_attachment" "function_logging_policy_attachment" {
  role = aws_iam_role.iam_for_lambda.id
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

data "archive_file" "lambda" {
  type        = "zip"
  source_dir = "lambda_function" # Para pastas, usar: source_dir 
  # source_file = "lambda_function.py" # Para pastas, usar: source_dir 
  # source_file = "${path.module}/lambda_function.py"
  output_path = "lambda_function_payload.zip"
}

resource "aws_lambda_function" "my_lambda" {
  filename      = "lambda_function_payload.zip"
  function_name = "minhaLambda"
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "lambda_function.lambda_metodo"

  source_code_hash = "${data.archive_file.lambda.output_base64sha256}"

  runtime = var.versao_python

# Coloco nos environments tudo que eu quiser que minha função lambda tenha acesso em 
# tempo de execução. Por exemplo: URL de banco de dados, usuário, senha...
  environment {
    variables = {
      variavel01 = "valor01"
    }
  }

  vpc_config {
    subnet_ids         = [aws_subnet.private-subnet.0.id]
    security_group_ids = [aws_security_group.allow_lambda.id]
  }

  depends_on = [aws_subnet.private-subnet.0]
}

resource "aws_s3_bucket_notification" "lambda_trigger" {
  bucket = aws_s3_bucket.my_bucket.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.my_lambda.arn
    events              = var.events_lambda_s3
    # filter_prefix       = "AWSLogs/"
    # filter_suffix       = ".log"
  }

  depends_on = [aws_lambda_permission.allow_bucket]
}

resource "aws_lambda_permission" "allow_bucket" {
  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.my_lambda.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = "arn:aws:s3:::${aws_s3_bucket.my_bucket.bucket}"
}

# Aqui eu crio um log group no cloudwatch... um log group pode ser considerado uma "pastinha" para armazenar todos os logs de uma determinada função
resource "aws_cloudwatch_log_group" "function_log_group" {
  name              = "/aws/lambda/${aws_lambda_function.my_lambda.function_name}"
  retention_in_days = var.logs_retention_cw
  lifecycle {
    prevent_destroy = false
  }
}

# Cria uma VPC, um tipo de rede privada dentro da AWS.
resource "aws_vpc" "dev-vpc" {
  cidr_block = "172.16.1.0/25"

  tags = {
    Name = "VPC 1 - DE-OP-009"
  }
}

resource "aws_subnet" "private-subnet" {
  count = var.subnet_count
  vpc_id            = aws_vpc.dev-vpc.id
  cidr_block        = var.subnet_cidr_block[count.index]
  availability_zone = var.subnet_az[count.index]

  tags = {
    Name = "Subnet ${count.index + 1} - DE-OP-009"
  }
}

resource "aws_security_group" "allow_lambda" {
  name        = "permite_conexao_lambda_rds"
  description = "Grupo de seguranca para permitir conexao ao db"
  vpc_id      = aws_vpc.dev-vpc.id

  egress {
    description = "Porta de conexao ao Postgres"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.dev-vpc.cidr_block] # aws_vpc.dev-vpc.cidr_blocks
  }

  tags = {
    Name = "DE-OP-009"
  }
}

resource "aws_db_subnet_group" "db-subnet" {
  name       = "db_subnet_group"
  subnet_ids = [aws_subnet.private-subnet[0].id, aws_subnet.private-subnet[1].id]
}

resource "aws_security_group" "allow_db" {
  name        = "permite_conexao_rds"
  description = "Grupo de seguranca para permitir conexao ao db"
  vpc_id      = aws_vpc.dev-vpc.id

  ingress {
    description = "Porta de conexao ao Postgres"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.dev-vpc.cidr_block] # aws_vpc.dev-vpc.cidr_blocks
  }

  tags = {
    Name = "DE-OP-009"
  }
}

resource "aws_db_instance" "postgres" {
  allocated_storage = 10 # Espaço em disco em GB!
  identifier        = "banquinho"
  db_name           = "mydb"
  engine            = "postgres"
  engine_version    = "12.9"
  instance_class    = "db.t3.micro"
  username          = "username" # Nome do usuário "master"
  password          = "password" # Senha do usuário master
  port              = 5432
  skip_final_snapshot    = true
  db_subnet_group_name   = aws_db_subnet_group.db-subnet.name
  vpc_security_group_ids = [aws_security_group.allow_db.id]
  
  depends_on = [
    aws_security_group.allow_db,
    aws_db_subnet_group.db-subnet
  ]
}
