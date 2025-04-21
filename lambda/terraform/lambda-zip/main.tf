# IAM Policy
data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

# IAM Role
resource "aws_iam_role" "lambda_role" {
  name               = var.iam_role_name
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

# IAM Role Policy
resource "aws_iam_role_policy" "lambda" {
  name = var.iam_policy_name
  role = aws_iam_role.lambda_role.name
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

# Archive Lambda Function
data "archive_file" "lambda_function_archive" {
  type        = "zip"
  source_dir  = "../../src"
  output_path = "lambda-function.zip"
}

# Lambda Function
resource "aws_lambda_function" "lambda_function" {
  filename         = data.archive_file.lambda_function_archive.output_path
  function_name    = var.lambda_function_name
  role             = aws_iam_role.lambda_role.arn
  handler          = "lambda_function.lambda_handler"
  memory_size      = 128
  source_code_hash = data.archive_file.lambda_function_archive.output_base64sha256
  runtime          = "python3.13"
  package_type     = "Zip"
}