output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = aws_lb.alb.dns_name
}

output "queue_url" {
  description = "SQS queue URL"
  value       = aws_sqs_queue.queue.id
}

output "bucket_name" {
  description = "S3 bucket name"
  value       = aws_s3_bucket.bucket.bucket
}