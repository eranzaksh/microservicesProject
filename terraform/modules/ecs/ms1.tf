resource "aws_ecs_task_definition" "ms1_task" {
  family                   = "ms1-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "512"
  memory                   = "1024"

  execution_role_arn = aws_iam_role.ecs_task_execution.arn
  task_role_arn      = aws_iam_role.ms1_task_role.arn

  container_definitions = jsonencode([
    {
      name      = "ms1"
      image     = "nginx:alpine" 
      essential = true
      portMappings = [
        {
          containerPort = 8000
          hostPort      = 8000
          protocol      = "tcp"
        }
      ]
      environment = [
        { "name": "SQS_QUEUE_URL", "value": var.sqs_queue_url },
        { "name": "TOKEN_PARAM_NAME", "value": var.token_param_name },
        { "name": "AWS_REGION", "value": var.aws_region }
      ]
    }
  ])
}




resource "aws_ecs_service" "ms1_service" {
  name            = "ms1-service"
  cluster         = aws_ecs_cluster.main.id
  launch_type     = "FARGATE"
  desired_count   = 1
  platform_version = "LATEST"

  task_definition = aws_ecs_task_definition.ms1_task.arn

  network_configuration {
    subnets         = var.private_subnets
    security_groups = [aws_security_group.ecs_sg.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.ingress_tg.arn
    container_name   = "ms1"
    container_port   = 8000
  }

  depends_on = [aws_lb_listener.http]
}
