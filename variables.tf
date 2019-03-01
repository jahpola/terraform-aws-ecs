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

variable "custom_userdata" {
  default     = ""
  description = "Inject extra command in the instance template to be run on boot"
}

variable "ecs_config" {
  default     = "echo '' > /etc/ecs/ecs.config"
  description = "Specify ecs configuration or get it from S3. Example: aws s3 cp s3://some-bucket/ecs.config /etc/ecs/ecs.config"
}

variable "ecs_logging" {
  default     = "[\"json-file\",\"awslogs\"]"
  description = "Adding logging option to ECS that the Docker containers can use. It is possible to add fluentd as well"
}

variable "alert_topic" {}
