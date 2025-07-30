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
    effect    = "Allow"
    resources = ["*"]
  }

  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    effect    = "Allow"
    resources = ["*"]
  }

  statement {
    actions = [
      "s3:CreateBucket",
      "s3:PutBucketPolicy",
      "s3:GetBucketPolicy",
      "s3:PutObject",
      "s3:GetObject",
      "s3:DeleteObject"
    ]
    effect    = "Allow"
    resources = ["*"]
  }

  statement {
    actions = [
      "cloudfront:CreateCloudFrontOriginAccessIdentity",
      "cloudfront:GetDistribution",
      "cloudfront:UpdateDistribution",
      "cloudfront:CreateDistribution",
      "cloudfront:GetCloudFrontOriginAccessIdentity"
    ]
    effect    = "Allow"
    resources = ["*"]
  }

  statement {
    actions = [
      "iam:CreatePolicy",
      "iam:CreateRole",
      "iam:PutRolePolicy",
      "iam:AttachRolePolicy",
      "iam:PassRole"
    ]
    effect    = "Allow"
    resources = ["*"]
  }

  statement {
    actions = [
      "apigateway:*"
    ]
    effect    = "Allow"
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "task_manager_assume_role_policy" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = ["arn:aws:iam::841162711590:oidc-provider/token.actions.githubusercontent.com"]
    }

    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:Elyn03/task-manager:ref:refs/heads/*"]
    }

    condition {
      test     = "StringLike"
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

resource "aws_iam_role_policy_attachment" "attach_s3_full" {
  role       = aws_iam_role.task_manager_apigateway_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_role_policy_attachment" "attach_cloudfront_full" {
  role       = aws_iam_role.task_manager_apigateway_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudFrontFullAccess"
}

resource "aws_iam_role_policy_attachment" "attach_iam_full" {
  role       = aws_iam_role.task_manager_apigateway_role.name
  policy_arn = "arn:aws:iam::aws:policy/IAMFullAccess"
}
