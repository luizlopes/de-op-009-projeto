variable "cidr_block" {
  default = "172.16.1.0/25"
}

variable "tag-sufix-name" {
  default = "DE-OP-009"
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
