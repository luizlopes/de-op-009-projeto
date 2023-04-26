variable "subnet_ids" {
  default     = []
  type        = list
}

variable "vpc_id" {
  default = ""
}

variable "vpc_cidr_block" {
  default = []
  type = list
}

variable "tag_sufix_name" {
  default = "DE-OP-009"
}

variable "db_identifier" {
  default = ""
}

variable "db_username" {
  default = ""
}

variable "db_password" {
  default = ""
}