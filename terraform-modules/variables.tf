# variables.tf placeholder
variable "Environment" {}
variable "Owner" {}
variable "vpc_cidr" {}
variable "instance_type" {}
variable "ami" {}
variable "db_name" {}
variable "db_username" {}
variable "db_password" {
  sensitive = true
}
#fdfdsf