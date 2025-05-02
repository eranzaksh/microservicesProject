variable "project_name" {
  type = string
  default = "eran-ecs"
}

variable "dockerhub_user" {
  type = string
  default = "eranzaksh"
}

variable "aws_region" {
  type = string
  default = "eu-north-1"
}

variable "token_param_name" {
  type = string
  default = "myapp/token"
  sensitive = true
}

variable "sqs_queue_url" {
  type = string
  default = "sqs"
}

variable "private_subnets" {
  type        = list(string)
}

variable "s3_bucket_name" {
  type = string
  default = "devops-assn-bucket-eranzaksh"
}