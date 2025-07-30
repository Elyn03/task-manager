data "archive_file" "lambda_archive" {
  type        = "zip"
  source_file = "${path.module}/lambda/index.mjs"
  output_path = "${path.module}/lambda/function.zip"
}

resource "aws_lambda_function" "lambda_function_over_https" {
  filename         = data.archive_file.lambda_archive.output_path
  function_name    = "LambdaFunctionOverHttps"
  role             = aws_iam_role.task_manager_lambda_role.arn
  handler          = "index.handler"
  source_code_hash = data.archive_file.lambda_archive.output_base64sha256
  runtime          = "nodejs18.x"
  tags             = var.tags
}
