variable "env" {
  default = "dev"
}

variable "ami" {
  default = "ami-045a533d19c34eeb6"
}

variable "instance_type" {
  default = "t3.small"
}

variable "vpc_security_group_ids" {
  default = [ "sg-09663d91a4fca31c9" ]
}

variable "zone_id" {
  default = "Z057881017RC0RRKVUX8E"
}

variable "components" {
  default = {
    mongodb = ""
    mysql = ""
    rabbitmq = ""
    redis = ""
  }
}

