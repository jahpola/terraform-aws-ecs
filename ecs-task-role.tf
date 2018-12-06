resource "aws_iam_role" "ecs_task_role" {
  name               = "ecs_task_role"
  path               = "/"
  assume_role_policy = "${data.aws_iam_policy_document.ecs_task_role}"
}

data "aws_iam_policy_document" "ecs_task_role" {
  statement {
    sid = "1"

    actions = [
      "ssm:GetParameters",
      "secretsmanager:GetSecretValue",
      "kms:Decrypt",
    ]

    resources = [
      "*",
    ]
  }
}
