# ====================== Lambda IAM Role ======================
resource "aws_iam_role" "lambda_role" {
  name = "${var.app_name}-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
}

# Basic execution + SQS permissions
resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "lambda_sqs" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSQSFullAccess"
}

data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "../lambda"
  output_path = "${path.module}/lambda.zip"
}
resource "aws_sqs_queue" "worker_dlq" {
  name = "${var.app_name}-worker-dlq"
}

# ===== Lambda Fuction ========================================
resource "aws_lambda_function" "worker" {
  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  function_name    = "${var.app_name}-worker"
  role             = aws_iam_role.lambda_role.arn
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.12"
  timeout = 30
  memory_size = 128

  environment {
    variables = {
      ENVIRONMENT = var.environment
    }
  }
}
resource "aws_lambda_function_event_invoke_config" "worker_invoke_config" {
  function_name = aws_lambda_function.worker.function_name
  maximum_event_age_in_seconds = 300
  maximum_retry_attempts =2
  destination_config {
    on_failure {
      destination = aws_sqs_queue.worker_dlq.arn
    }
  
  }
  
}

# ====================== Allow Lambda to write to DLQ (Policy) ======================
resource "aws_iam_role_policy" "lambda_dlq_policy" {
  name = "${var.app_name}-lambda-dlq-policy"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [ "sqs:SendMessage"]      
      Resource = aws_sqs_queue.worker_dlq.arn
    }]
  })
  
}

# ====================== SQS Trigger for Lambda ======================
resource "aws_lambda_event_source_mapping" "sqs_trigger" {
  event_source_arn = aws_sqs_queue.main.arn
  function_name    = aws_lambda_function.worker.arn
  batch_size       = 10
  enabled          = true

  depends_on = [aws_lambda_function.worker]
}