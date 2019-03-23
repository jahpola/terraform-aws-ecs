# AWS ECS module

[![Sponsored](https://img.shields.io/badge/chilicorn-sponsored-brightgreen.svg)](http://spiceprogram.org/oss-sponsorship/)

Yet another ECS Terraform module...

## User data 

TODO: 
- create a user data script
- add cloudwatch logging
- add ssm agent


## How to use

Assumes that you have existing VPC setup with several remote data provided:

- private subnets
- ec2 instance security group for ECS instances to join

Also you need:
- keypair

Then you use it as a module in Terraform:

```terraform
module "ecs-cluster" {
  source            = "../../terraform-aws-ecs/"
  ecs_cluster       = "backend-${var.environment}"
  environment       = "${var.environment}"
  min_instance_size = "1"
  max_instance_size = "2"
  desired_capacity  = "1"
  instance_type     = "t2.small"
  ecs_key_pair_name = "${var.ecs_key_pair_name}"
  ecs_instance_sg   = "${module.ecs-instance-dev-sg.this_security_group_id}"
  private_subnets   = "${data.terraform_remote_state.shared.private_subnets}"
}
```

