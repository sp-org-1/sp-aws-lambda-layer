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

# Archive Lambda Layer
data "archive_file" "lambda_layer_archive" {
  type        = "zip"
  source_dir  = "../../layer"
  excludes    = ["Scripts", "bin", "Include", "Lib", "*.cfg"]
  output_path = "lambda-layer.zip"
}

# Archive Lambda Function
data "archive_file" "lambda_function_archive" {
  type        = "zip"
  source_dir  = "../../src"
  output_path = "lambda-function.zip"
}

# Lambda Layer S3 Object
resource "aws_s3_object" "lambda_layer_object" {
  bucket = var.s3_bucket_name
  key    = "lambda-layer.zip"
  source = data.archive_file.lambda_layer_archive.output_path
  etag   = data.archive_file.lambda_layer_archive.output_base64sha256

  depends_on = [
    data.archive_file.lambda_layer_archive
  ]
}

# Lambda Layer
resource "aws_lambda_layer_version" "lambda_layer" {
  layer_name       = var.lambda_layer_name
  s3_bucket        = var.s3_bucket_name
  s3_key           = var.s3_object_name
  source_code_hash = data.archive_file.lambda_function_archive.output_base64sha256

  compatible_runtimes = ["python3.13"]
  depends_on = [
    aws_s3_object.lambda_layer_object
  ]
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
  layers           = [aws_lambda_layer_version.lambda_layer.arn]
  package_type     = "Zip"
}