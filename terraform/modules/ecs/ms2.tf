resource "aws_ecs_task_definition" "ms2_task" {
  family                   = "ms1-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "512"
  memory                   = "1024"

  execution_role_arn = aws_iam_role.ecs_task_execution.arn
  task_role_arn      = aws_iam_role.ms2_task_role.arn

  container_definitions = jsonencode([
    {
      name      = "ms2"
      image     = "nginx:alpine" 
      essential = true

      environment = [
        { "name": "SQS_QUEUE_URL", "value": var.sqs_queue_url },
        { "name": "S3_BUCKET_NAME", "value": var.s3_bucket_name },
        { "name": "AWS_REGION", "value": var.aws_region }
      ]
    }
  ])
}


resource "aws_ecs_service" "ms2_service" {
  name            = "ms2-service"
  cluster         = aws_ecs_cluster.main.id
  launch_type     = "FARGATE"
  desired_count   = 1
  platform_version = "LATEST"

  task_definition = aws_ecs_task_definition.ms2_task.arn

  network_configuration {
    subnets         = var.private_subnets
    security_groups = [aws_security_group.ecs_sg.id]
    assign_public_ip = false
  }
}