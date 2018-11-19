resource "aws_ecs_cluster" "ecs-cluster" {
  name = "${var.ecs_cluster}"
}

data "aws_ssm_parameter" "ecs_ami_id" {
  name = "/aws/service/ecs/optimized-ami/amazon-linux/recommended/image_id"
}

data "template_file" "user_data" {
  template = "${file("${path.module}/templates/user_data.sh")}"

  vars {
    ecs_config      = "${var.ecs_config}"
    ecs_logging     = "${var.ecs_logging}"
    cluster_name    = "${var.ecs_cluster}"
    env_name        = "${var.environment}"
    custom_userdata = "${var.custom_userdata}"
  }
}

resource "aws_launch_configuration" "ecs-launch-configuration" {
  name_prefix          = "backend-cluster-${var.environment}"
  image_id             = "${data.aws_ssm_parameter.ecs_ami_id.value}"
  instance_type        = "${var.instance_type}"
  iam_instance_profile = "${aws_iam_instance_profile.ecs-instance-profile.id}"

  # root_block_device {
  #   volume_type           = "standard"
  #   volume_size           = 25
  #   delete_on_termination = true
  # }

  lifecycle {
    create_before_destroy = true
  }
  security_groups = ["${var.ecs_instance_sg}"]
  key_name        = "${var.ecs_key_pair_name}"
  user_data       = "${data.template_file.user_data.rendered}"

  # user_data = <<EOF
  #   #!/bin/bash
  #   echo ECS_CLUSTER=${var.ecs_cluster} >> /etc/ecs/ecs.config
  #   EOF
}

resource "aws_autoscaling_group" "ecs-autoscaling-group" {
  max_size         = "${var.max_instance_size}"
  min_size         = "${var.min_instance_size}"
  desired_capacity = "${var.desired_capacity}"

  vpc_zone_identifier = ["${join(",", sort(var.private_subnets))}"]

  launch_configuration = "${aws_launch_configuration.ecs-launch-configuration.name}"
  health_check_type    = "ELB"

  tag {
    key                 = "Terraform"
    value               = "True"
    propagate_at_launch = true
  }

  tag {
    key                 = "Environment"
    value               = "${var.environment}"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_policy" "ecs-cpu-policy-scaleup" {
  name                   = "ecs-cpu-policy-scaleup"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = "${aws_autoscaling_group.ecs-autoscaling-group.name}"
  policy_type            = "SimpleScaling"
}

resource "aws_cloudwatch_metric_alarm" "ecs-cpu-alarm-scaleup" {
  alarm_name          = "ecs-cpu-alarm-scaleup"
  alarm_description   = "ecs-cpu-alarm-scaleup"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "75"

  dimensions = {
    "AutoScalingGroupName" = "${aws_autoscaling_group.ecs-autoscaling-group.name}"
  }

  actions_enabled = true
  alarm_actions   = ["${aws_autoscaling_policy.ecs-cpu-policy-scaleup.arn}"]
}

# scale down alarm
resource "aws_autoscaling_policy" "ecs-cpu-policy-scaledown" {
  name                   = "ecs-cpu-policy-scaledown"
  autoscaling_group_name = "${aws_autoscaling_group.ecs-autoscaling-group.name}"
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = "-1"
  cooldown               = "300"
  policy_type            = "SimpleScaling"
}

resource "aws_cloudwatch_metric_alarm" "ecs-cpu-alarm-scaledown" {
  alarm_name          = "ecs-cpu-alarm-scaledown"
  alarm_description   = "ecs-cpu-alarm-scaledown"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "10"

  dimensions = {
    "AutoScalingGroupName" = "${aws_autoscaling_group.ecs-autoscaling-group.name}"
  }

  actions_enabled = true
  alarm_actions   = ["${aws_autoscaling_policy.ecs-cpu-policy-scaledown.arn}"]
}
