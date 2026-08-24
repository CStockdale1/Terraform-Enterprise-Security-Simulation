resource "aws_iam_role" "application" {
  name = "company-application-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "ec2.amazonaws.com"
        }

        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name = "company-application-role"
    Tier = "application"
  }
}

resource "aws_iam_policy" "application_storage" {
  name        = "company-application-storage-policy"
  description = "Allows application workloads to access the application S3 bucket"

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Action = [
          "s3:GetObject",
          "s3:PutObject"
        ]

        Resource = "${var.bucket_arn}/*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "application_storage" {
  role       = aws_iam_role.application.name
  policy_arn = aws_iam_policy.application_storage.arn
}
