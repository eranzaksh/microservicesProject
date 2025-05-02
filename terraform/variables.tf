
variable "public_subnet_cidrs" {
  type        = list(string)
  description = "Public Subnet CIDR values"
  default     = ["10.1.1.0/24", "10.1.2.0/24"]
}

variable "private_subnet_cidrs" {
  type        = list(string)
  description = "Private Subnet CIDR values"
  default     = ["10.1.3.0/24", "10.1.4.0/24"]
}

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
  default = "/myapp/token"
  sensitive = true
}

variable "sqs_queue_url" {
  type = string
  default = "sqs"
}

variable "s3_bucket_name" {
  type = string
  default = "devops-assn-bucket-eranzaksh"
}