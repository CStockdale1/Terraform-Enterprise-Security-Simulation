output "application_role_arn" {
  description = "ARN of the application IAM role"
  value       = aws_iam_role.application.arn
}

output "application_policy_arn" {
  description = "ARN of the application storage policy"
  value       = aws_iam_policy.application_storage.arn
}
