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

resource "aws_iam_policy" "lambda_policy" {
  name   = "function-logging-policy"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        Action : [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Effect : "Allow",
        Resource : "arn:aws:logs:*:*:*"
      },
      {
          Effect: "Allow",
          Action: [
              "s3:*"
          ],
          Resource: "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" {
  role = aws_iam_role.iam_for_lambda.id
  policy_arn = aws_iam_policy.lambda_policy.arn
}

resource "aws_iam_role_policy_attachment" "lambda_network_policy_attachment" {
  role = aws_iam_role.iam_for_lambda.id
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

data "archive_file" "lambda" {
  type        = var.file_type #"zip"
  source_dir  = var.source_dir #"lambda_function" # Para pastas, usar: source_dir 
  output_path = var.output_path #"lambda_function_payload.zip"
}

resource "aws_lambda_function" "my_lambda" {
  filename      = var.output_path # "lambda_function_payload.zip"
  function_name = var.function_name #"minhaLambda"
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = var.handler #"lambda_function.lambda_metodo"

  source_code_hash = "${data.archive_file.lambda.output_base64sha256}"

  runtime = var.versao_python

  layers = ["arn:aws:lambda:us-east-1:336392948345:layer:AWSSDKPandas-Python39:6"]

# Coloco nos environments tudo que eu quiser que minha função lambda tenha acesso em 
# tempo de execução. Por exemplo: URL de banco de dados, usuário, senha...
  environment {
    variables = {
      DATABASE_HOST = var.env_database_host # aws_db_instance.postgres.address
      DATABASE_USERNAME = var.env_database_username # aws_db_instance.postgres.username
      DATABASE_PASSWORD = var.env_database_password # aws_db_instance.postgres.password
      DATABASE_NAME = var.env_database_name # aws_db_instance.postgres.db_name
      DATABASE_PORT = var.env_database_port # aws_db_instance.postgres.port
    }
  }

  vpc_config {
    subnet_ids         = [var.subnet_ids.0.id] #[aws_subnet.private-subnet.0.id]
    security_group_ids = [aws_security_group.allow_lambda.id]
  }

  # depends_on = [aws_subnet.private-subnet.0]
}

resource "aws_s3_bucket_notification" "lambda_trigger" {
  bucket = var.bucket_id # aws_s3_bucket.my_bucket.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.my_lambda.arn
    events              = var.events_lambda_s3
  }

  depends_on = [aws_lambda_permission.allow_bucket]
}

resource "aws_lambda_permission" "allow_bucket" {
  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.my_lambda.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = "arn:aws:s3:::${var.bucket_name}"
}

# Aqui eu crio um log group no cloudwatch... um log group pode ser considerado uma "pastinha" para armazenar todos os logs de uma determinada função
resource "aws_cloudwatch_log_group" "function_log_group" {
  name              = "/aws/lambda/${aws_lambda_function.my_lambda.function_name}"
  retention_in_days = var.logs_retention_cw
  lifecycle {
    prevent_destroy = false
  }
}

resource "aws_security_group" "allow_lambda" {
  name        = "permite_conexao_lambda_rds"
  description = "Grupo de seguranca para permitir conexao ao db"
  vpc_id      = var.vpc_id

  egress {
    description = "Porta de conexao ao Postgres"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = var.cidr_blocks  # [aws_vpc.dev-vpc.cidr_block] # aws_vpc.dev-vpc.cidr_blocks
  }

  tags = {
    Name = "DE-OP-009"
  }
}