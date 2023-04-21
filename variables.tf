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

variable "subnet_cidr_block" {
    type = list
    default = ["172.16.1.48/28", "172.16.1.64/28"]
    description = "CIDR block"
}

variable "subnet_az" {
    type = list
    default = ["us-east-1a", "us-east-1b"]
    description = "Subnet Available Zone"
}

variable "subnet_count" {
    type = number
    default = 2
    description = "Number of subnets"
}

variable "versao_python" {
  type = string
  default = "python3.9"
  description = "Versão do python para executar a função."
}
