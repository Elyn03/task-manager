output "cloudfront_distribution_domain_name" {
  value = module.cdn.cloudfront_distribution_domain_name
}

output "cloudfront_distribution_id" {
  value = module.cdn.cloudfront_distribution_id
}

output "s3_bucket_name" {
  value = aws_s3_bucket.main.bucket
}

output "api_gateway_url" {
  value = "https://${aws_api_gateway_rest_api.dynamo_db_operations.id}.execute-api.eu-west-1.amazonaws.com/${aws_api_gateway_stage.dynamodb_manager.stage_name}"
}