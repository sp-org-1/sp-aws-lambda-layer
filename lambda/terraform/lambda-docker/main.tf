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

# Lambda Function
resource "aws_lambda_function" "lambda_function" {
  function_name = var.lambda_function_name
  role          = aws_iam_role.lambda_role.arn
  memory_size = 128
  runtime = "python3.12"
  package_type = "Image"
  image_uri    = "291912718832.dkr.ecr.us-east-1.amazonaws.com/lambda-docker-image:1.0"
}