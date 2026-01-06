terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = "us-east-2"
}

resource "aws_s3_bucket" "mybucket" {
  bucket = "vishnu-resume-bucket-2026"
}

resource "aws_s3_bucket_public_access_block" "bucket_block" {
  bucket = aws_s3_bucket.mybucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
resource "aws_dynamodb_table" "mytable" {
  name         = "Dynamodbtable"
  billing_mode = "PAY_PER_REQUEST"

  hash_key = "Id"

  attribute {
    name = "Id"
    type = "S"
  }
}

resource "aws_dynamodb_table_item" "home" {
  table_name = aws_dynamodb_table.mytable.name
  hash_key   = aws_dynamodb_table.mytable.hash_key

  item = jsonencode({
    Id    = { S = "home" }
    count = { N = "0" }
  })
}


data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/lambda.py"
  output_path = "${path.module}/lambda.zip"
}

resource "aws_iam_role" "lambda_role" {
  name = "lamdarole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect    = "Allow",
      Principal = { Service = "lambda.amazonaws.com" },
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_policy" "ddb_policy" {
  name = "lamda-dynamodb-policy"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect   = "Allow",
      Action   = ["dynamodb:GetItem", "dynamodb:PutItem", "dynamodb:UpdateItem"],
      Resource = aws_dynamodb_table.mytable.arn
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ddb_attach" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.ddb_policy.arn
}


resource "aws_lambda_function" "counter" {
  function_name = "counter-function"
  role          = aws_iam_role.lambda_role.arn

  runtime = "python3.12"
  handler = "lambda.lambda_handler"

  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
}

resource "aws_lambda_function_url" "counter_url" {
  function_name      = aws_lambda_function.counter.function_name
  authorization_type = "NONE"

  cors {
    allow_origins = ["*"]
    allow_methods = ["GET"]
    allow_headers = ["content-type"]
  }
}

output "counter_url" {
  value = aws_lambda_function_url.counter_url.function_url
}

