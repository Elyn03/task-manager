resource "aws_iam_policy" "task_manager_apigateway_policy" {
  name        = "task-manager-apigateway-policy"
  description = "task_manager_execution_policy"
  policy = data.aws_iam_policy_document.task_manager_execution_policy_document.json
}

data "aws_iam_policy_document" "task_manager_execution_policy_document" {
  statement {
    actions = [
      "dynamodb:DeleteItem",
        "dynamodb:GetItem",
        "dynamodb:PutItem",
        "dynamodb:Query",
        "dynamodb:Scan",
        "dynamodb:UpdateItem"
    ]
    effect = "Allow"
    resources = [
      "*",
    ]
  }
  statement {
    actions = [
       "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
    ]
    effect = "Allow"
    resources = [
      "*",
    ]
  }
}

data "aws_iam_policy_document" "task_manager_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "task_manager_apigateway_role" {
  name = "task-manager-apigateway-role"
  assume_role_policy = data.aws_iam_policy_document.task_manager_assume_role_policy.json

}

resource "aws_iam_role_policy_attachment" "task_manager_apigateway_attachment" {
  role       = aws_iam_role.task_manager_apigateway_role.name
  policy_arn = aws_iam_policy.task_manager_apigateway_policy.arn
}
