output "ecs_cluster_id" {
  value = "${element(concat(aws_ecs_cluster.ecs-cluster.*.id, list("")), 0)}"
}

output "ecs_cluster_arn" {
  value = "${element(concat(aws_ecs_cluster.ecs-cluster.*.arn, list("")), 0)}"
}

output "ecs_cluster_service_role_arn" {
    value ="${aws_iam_role.ecs-service-role.arn}"
}

output "ecs_cluster_service_role_id" {
    value ="${aws_iam_role.ecs-service-role.id}"
}