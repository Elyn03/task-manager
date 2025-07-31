output "cloudfront_distribution_domain_name" {
  value = module.cdn.cloudfront_distribution_domain_name
}

output "github_actions_role_arn" {
  value       = aws_iam_role.task_manager_apigateway_role.arn
  description = "ARN du rôle IAM pour GitHub Actions"
}

output "lambda_role_arn" {
  value       = aws_iam_role.task_manager_lambda_role.arn
  description = "ARN du rôle IAM pour Lambda"
}
