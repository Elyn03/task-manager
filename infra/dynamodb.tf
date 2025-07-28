resource "aws_dynamodb_table" "task_manager_apigateway_table" {
  name         = "task-manager-apigateway"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }

  tags = var.tags
}
