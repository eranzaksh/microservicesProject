# Basic role for ECS Task Execution
resource "aws_iam_role" "ecs_task_execution" {
  name = "ecsTaskExecutionRole"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_assume_role.json
}

# Trust relationship for ECS tasks
data "aws_iam_policy_document" "ecs_task_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

# Attach AWS managed ECS task execution policy
resource "aws_iam_role_policy_attachment" "ecs_execution_policy" {
  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}


# Dedicated IAM Role for MS1
resource "aws_iam_role" "ms1_task_role" {
  name = "ms1TaskRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

# Create Dedicated IAM Role for MS2 with SQS and S3 Access
resource "aws_iam_role" "ms2_task_role" {
  name = "ms2TaskRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "ms1_sqs_access" {
  name = "shared-sqs-access"
  role = aws_iam_role.ms1_task_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "sqs:SendMessage",
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueUrl",
          "sqs:ChangeMessageVisibility"
        ]
        Effect   = "Allow"
        Resource = aws_sqs_queue.queue.arn
      }
    ]
  })
}

resource "aws_iam_role_policy" "ms2_sqs_access" {
  name = "ms2-sqs-access"
  role = aws_iam_role.ms2_task_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "sqs:SendMessage",
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueUrl",
          "sqs:ChangeMessageVisibility"
        ]
        Effect   = "Allow"
        Resource = aws_sqs_queue.queue.arn
      }
    ]
  })
}

resource "aws_iam_role_policy" "ms2_s3_access" {
  name = "ms2-s3-access"
  role = aws_iam_role.ms2_task_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:PutObject",
          "s3:PutObjectAcl"
        ]
        Effect   = "Allow"
        Resource = "${aws_s3_bucket.bucket.arn}/*"
      }
    ]
  })
}



# SSM Parameter Store Access for MS1
resource "aws_iam_role_policy" "ms1_ssm_access" {
  name = "ms1-ssm-token-access"
  role = aws_iam_role.ms1_task_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ssm:GetParameter",
          "ssm:GetParameters",
          "ssm:GetParametersByPath"
        ]
        Effect   = "Allow"
        Resource = "arn:aws:ssm:${var.aws_region}:${data.aws_caller_identity.current.account_id}:parameter/myapp/token"
      }
    ]
  })
}

data "aws_caller_identity" "current" {}
