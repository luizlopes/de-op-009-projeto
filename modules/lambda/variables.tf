variable "file_type" {
    default = ""
}

variable "source_dir" {
    default = ""
}

variable "output_path" {
    default = ""
}

variable "function_name" {
    default = ""
}

variable "handler" {
    default = ""
}

variable "versao_python" {
  type = string
  default = "python3.9"
  description = "Versão do python para executar a função."
}

variable "events_lambda_s3" {
  type = list
  default = ["s3:ObjectCreated:*", "s3:ObjectRemoved:*"]
  description = "Lista de eventos a serem notificados pelo bucket S3"
}

variable "logs_retention_cw" {
  type = number
  default = 1
  description = "tempo de retencao dos logs no CloudWatch em dias"
}

variable "subnet_ids" {
    default = []
    type = list
    description = "vpc config"
}

variable "security_group_ids" {
    default = []
    type = list
    description = "vpc config"
}

variable "vpc_id" {
    default = ""
}

variable "cidr_blocks" {
    default = []
    type = list
}

variable bucket_id {
    default = ""
}

variable bucket_name {
    default = ""
}

variable "env_database_host" {
    default = ""
}

variable "env_database_username" {
    default = ""
}

variable "env_database_password" {
    default = ""
}

variable "env_database_name" {
    default = ""
}

variable "env_database_port" {
    default = ""
}