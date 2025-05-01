resource "aws_sqs_queue" "queue" {
  name                       = "devops-queue"
  visibility_timeout_seconds = 30
}

resource "aws_s3_bucket" "bucket" {
  bucket = "devops-assn-bucket-eranzaksh"
}
