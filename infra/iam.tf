
# OIDC Provider pour GitHub Actions
resource "aws_iam_openid_connect_provider" "github_actions" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = [
    "sts.amazonaws.com",
  ]

  thumbprint_list = [
    "6938fd4d98bab03faadb97b34396831e3780aea1",
    "1c58a3a8518e8759bf075b76b750d4f2df264fcd"
  ]

  tags = {
    Name        = "GitHub Actions OIDC Provider"
    Environment = "dev"
  }
}

# Politiques IAM
resource "aws_iam_policy" "github_actions_deployment_policy" {
  name        = "github-actions-deployment-policy"
  description = "Politique pour déploiement GitHub Actions"
  policy      = data.aws_iam_policy_document.github_actions_deployment_policy_document.json
}

data "aws_iam_policy_document" "github_actions_deployment_policy_document" {
  # Permissions DynamoDB
  statement {
    actions = [
      "dynamodb:*"
    ]
    effect    = "Allow"
    resources = ["*"]
  }

  # Permissions S3
  statement {
    actions = [
      "s3:*"
    ]
    effect    = "Allow"
    resources = ["*"]
  }

  # Permissions CloudFront
  statement {
    actions = [
      "cloudfront:*"
    ]
    effect    = "Allow"
    resources = ["*"]
  }

  # Permissions Lambda
  statement {
    actions = [
      "lambda:*"
    ]
    effect    = "Allow"
    resources = ["*"]
  }

  # Permissions API Gateway
  statement {
    actions = [
      "apigateway:*"
    ]
    effect    = "Allow"
    resources = ["*"]
  }

  # Permissions IAM (pour créer/modifier les rôles)
  statement {
    actions = [
      "iam:*"
    ]
    effect    = "Allow"
    resources = ["*"]
  }

  # Permissions CloudWatch Logs
  statement {
    actions = [
      "logs:*"
    ]
    effect    = "Allow"
    resources = ["*"]
  }

  # Permissions pour les tags
  statement {
    actions = [
      "tag:*"
    ]
    effect    = "Allow"
    resources = ["*"]
  }

  # Permissions STS
  statement {
    actions = [
      "sts:GetCallerIdentity",
      "sts:AssumeRole"
    ]
    effect    = "Allow"
    resources = ["*"]
  }
}

resource "aws_iam_policy" "task_manager_apigateway_policy" {
  name        = "task-manager-apigateway-policy"
  description = "task_manager_execution_policy"
  policy      = data.aws_iam_policy_document.task_manager_execution_policy_document.json
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
    effect = "Allow"

    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github_actions.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    # Condition plus spécifique selon les recommandations GitHub/AWS
    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values = [
        "repo:Elyn03/task-manager:*",
        "repo:Elyn03/task-manager:ref:refs/heads/*",
        "repo:Elyn03/task-manager:ref:refs/pull/*"
      ]
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

# Attachement de la politique GitHub Actions pour déploiement complet
resource "aws_iam_role_policy_attachment" "github_actions_deployment_attachment" {
  role       = aws_iam_role.task_manager_apigateway_role.name
  policy_arn = aws_iam_policy.github_actions_deployment_policy.arn
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
