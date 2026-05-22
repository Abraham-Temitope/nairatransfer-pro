# ====================== SQS ======================
resource "aws_sqs_queue" "main" {
  name                      = "${var.app_name}-main-queue"
  delay_seconds             = 0
  max_message_size          = 262144
  message_retention_seconds = 86400   # 1 day
  receive_wait_time_seconds = 20

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dlq.arn
    maxReceiveCount     = 5
  })

  tags = {
    Name        = "${var.app_name}-main-queue"
    Environment = var.environment
  }
}

resource "aws_sqs_queue" "dlq" {
  name                      = "${var.app_name}-dlq"
  message_retention_seconds = 86400   # 1 day

  tags = {
    Name        = "${var.app_name}-dlq"
    Environment = var.environment
  }
}