provider "aws" {
  region = "ap-south-1"
}

data "aws_caller_identity" "current" {}


# 1️⃣ Create the Lambda function
resource "aws_lambda_function" "example" {
  function_name = "scheduled-lambda"
  role          = aws_iam_role.lambda_exec.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.9"
  timeout       = 900
  memory_size   = 128

  filename         = "lambda_function.zip" # Path to your packaged code
  source_code_hash = filebase64sha256("lambda_function.zip")
}

# 2️⃣ IAM Role for Lambda
resource "aws_iam_role" "lambda_exec" {
  name = "lambda_exec_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}


# 3️⃣ Attach basic execution policy
resource "aws_iam_role_policy_attachment" "lambda_logging" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# 4️⃣ Create EventBridge rule (schedule)
resource "aws_cloudwatch_event_rule" "every_five_minutes" {
  name                = "every-five-minutes"
  description         = "Trigger Lambda every 5 minutes"
#   schedule_expression = "rate(5 minutes)"
  schedule_expression = "cron(0/5 * * * ? *)"

}

# 5️⃣ Add the Lambda target
resource "aws_cloudwatch_event_target" "invoke_lambda" {
  rule      = aws_cloudwatch_event_rule.every_five_minutes.name
  target_id = "lambda"
  arn       = aws_lambda_function.example.arn
}

# 6️⃣ Allow EventBridge to invoke the Lambda
resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.example.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.every_five_minutes.arn
}

#-----------------------------------------------------------------------------------
# Pushing logs into s3 bucket using lambda

# S3  creation
resource "aws_s3_bucket" "cw_logs_bucket" {
  bucket = "my-cw-log-export-bucket-12345" 
  force_destroy = true  
}

# Iam role creation for lambda
resource "aws_iam_role" "lambda_s3_role" {
  name = "cwlogs_to_s3_lambda_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Action = "sts:AssumeRole",
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

# Policy creation for Iam role
resource "aws_iam_role_policy" "lambda_s3_policy" {
  name = "cwlogs_to_s3_lambda_policy"
  role = aws_iam_role.lambda_s3_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:PutObject",
          "s3:PutObjectAcl"
        ],
        Resource = "${aws_s3_bucket.cw_logs_bucket.arn}/*"
      },
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}

# Creating lambda function
resource "aws_lambda_function" "cwlogs_to_s3" {
  function_name = "cwlogs_to_s3_forwarder"
  filename      = "lambda.zip"
  handler       = "lambda.lambda_handler"
  runtime       = "python3.12"
  role          = aws_iam_role.lambda_s3_role.arn
  timeout       = 30
}

# Creating cloud watch log group
resource "aws_cloudwatch_log_group" "app_log_group" {
  name              = "/aws/logs"
  retention_in_days = 14
}

resource "aws_lambda_permission" "allow_cloudwatch" {
  statement_id  = "AllowExecutionFromCloudWatchLogs"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.cwlogs_to_s3.function_name
  principal     = "logs.ap-south-1.amazonaws.com"

source_arn = "arn:aws:logs:ap-south-1:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/scheduled-lambda:*"
}


# CloudWatch → Lambda: Subscription Filter
resource "aws_cloudwatch_log_subscription_filter" "cw_to_s3_filter" {
  name            = "cw-to-s3-subscription"
 log_group_name = "/aws/lambda/scheduled-lambda"
  destination_arn = aws_lambda_function.cwlogs_to_s3.arn
  filter_pattern  = ""     # Capture ALL logs

  depends_on = [
    aws_lambda_permission.allow_cloudwatch
  ]
}

resource "aws_iam_role_policy_attachment" "cwlogs_s3_basic" {
  role       = aws_iam_role.lambda_s3_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}
