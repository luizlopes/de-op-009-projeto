terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }

  backend "s3" {
    bucket = "de-op-009-backend-luiz"
    key    = "terraform"
    region = "us-east-1"
  }
}

provider "aws" {
  # profile    = "bootcamp" # Aqui vai o "profile" que você configurou as credenciais da AWS.
  region     = "us-east-1"
}
