resource "aws_iam_policy" "task_manager_apigateway_policy" {
  name        = "task-manager-apigateway-policy"
  description = "task_manager_execution_policy"
  policy      = data.aws_iam_policy_document.task_manager_execution_policy_document.json
}

data "aws_iam_policy_document" "task_manager_execution_policy_document" {
  # Permissions DynamoDB complètes
  statement {
    actions = [
      "dynamodb:*"
    ]
    effect = "Allow"
    resources = ["*"]
  }

  # Permissions CloudWatch Logs
  statement {
    actions = [
      "logs:*"
    ]
    effect = "Allow"
    resources = ["*"]
  }

  # Permissions IAM complètes
  statement {
    actions = [
      "iam:*"
    ]
    effect = "Allow"
    resources = ["*"]
  }

  # Permissions Lambda complètes
  statement {
    actions = [
      "lambda:*"
    ]
    effect = "Allow"
    resources = ["*"]
  }

  # Permissions API Gateway complètes
  statement {
    actions = [
      "apigateway:*"
    ]
    effect = "Allow"
    resources = ["*"]
  }

  # Permissions S3 complètes
  statement {
    actions = [
      "s3:*"
    ]
    effect = "Allow"
    resources = ["*"]
  }

  # Permissions CloudFront complètes
  statement {
    actions = [
      "cloudfront:*"
    ]
    effect = "Allow"
    resources = ["*"]
  }

  # Permissions pour les tags
  statement {
    actions = [
      "tag:GetResources",
      "tag:TagResources",
      "tag:UntagResources",
      "tag:GetTagKeys",
      "tag:GetTagValues"
    ]
    effect = "Allow"
    resources = ["*"]
  }

  # Permissions pour STS (nécessaire pour assume role)
  statement {
    actions = [
      "sts:GetCallerIdentity",
      "sts:AssumeRole"
    ]
    effect = "Allow"
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "task_manager_assume_role_policy" {
  statement {
    effect = "Allow"

    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = ["arn:aws:iam::841162711590:oidc-provider/token.actions.githubusercontent.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:Elyn03/task-manager:*"]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "task_manager_apigateway_role" {
  name               = "task-manager-apigateway-role"
  assume_role_policy = data.aws_iam_policy_document.task_manager_assume_role_policy.json

}

resource "aws_iam_role_policy_attachment" "task_manager_apigateway_attachment" {
  role       = aws_iam_role.task_manager_apigateway_role.name
  policy_arn = aws_iam_policy.task_manager_apigateway_policy.arn
}

# Rôle IAM spécifique pour Lambda
data "aws_iam_policy_document" "lambda_assume_role_policy" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "task_manager_lambda_role" {
  name               = "task-manager-lambda-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role_policy.json
}

resource "aws_iam_role_policy_attachment" "task_manager_lambda_attachment" {
  role       = aws_iam_role.task_manager_lambda_role.name
  policy_arn = aws_iam_policy.task_manager_apigateway_policy.arn
}

# Politique pour les logs CloudWatch pour Lambda
resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.task_manager_lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}
