module "bucket_s3" {
  source      = "./modules/s3"
  bucket_name = "bucket-de-op-009-luiz-lopes"
}

module "network" {
  source      = "./modules/network"
}

module "rds" {
  source          = "./modules/rds"
  vpc_id          = module.network.vpc_id
  subnet_ids      = [module.network.subnet_ids.0.id, module.network.subnet_ids.1.id]
  vpc_cidr_block  = [module.network.vpc_cidr_block]
  db_identifier   = "banco-xpto"
  db_username     = "usuario"
  db_password     = "senha123"
}

module "lambda" {
  source              = "./modules/lambda"
  file_type           = "zip"
  source_dir          = "lambda_function"
  output_path         = "lambda_function.zip"
  function_name       = "minha-lambda"
  handler             = "lambda_function.lambda_metodo"
  
  # bucket
  bucket_id           = module.bucket_s3.bucket_id
  bucket_name         = module.bucket_s3.bucket_name

  # vpc_config
  subnet_ids          = module.network.subnet_ids
  # security_group_ids  = [aws_security_group.allow_lambda.id]

  # allow rds conection
  vpc_id              = module.network.vpc_id
  cidr_blocks         = [module.network.vpc_cidr_block]

  # environment
  env_database_host       = module.rds.address
  env_database_username   = module.rds.username
  env_database_password   = module.rds.password
  env_database_name       = module.rds.db_name
  env_database_port       = module.rds.database_port
}
