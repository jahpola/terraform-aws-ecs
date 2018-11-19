variable "ecs_cluster" {
  default = "test-cluster"
}

variable "environment" {}

variable "min_instance_size" {
  default = 1
}

variable "max_instance_size" {
  default = 1
}

variable "desired_capacity" {
  default = 1
}

variable "ecs_key_pair_name" {}

variable "private_subnets" {
  type = "list"
}

variable "ecs_instance_sg" {}

variable "instance_type" {
  default = "t2.small"
}

