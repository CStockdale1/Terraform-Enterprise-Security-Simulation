output "logs_bucket_name" {
  description = "Name of the security logging bucket"
  value       = aws_s3_bucket.logs.bucket
}

output "logs_bucket_arn" {
  description = "ARN of the security logging bucket"
  value       = aws_s3_bucket.logs.arn
}
