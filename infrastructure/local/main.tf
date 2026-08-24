terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

provider "aws" {
  region     = "us-east-1"
  access_key = "test"
  secret_key = "test"

  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true

  s3_use_path_style = true

  endpoints {
    ec2       = "http://localhost:4566"
    iam       = "http://localhost:4566"
    s3        = "http://s3.localhost.localstack.cloud:4566"
    s3control = "http://localhost.localstack.cloud:4566"
    sts       = "http://localhost:4566"
  }
}

module "networking" {
  source = "../../modules/networking"
}

resource "aws_s3_bucket" "test" {
  bucket = "enterprise-security-lab-test"
}

module "iam" {
  source = "../../modules/iam"

  bucket_arn = aws_s3_bucket.test.arn
}


module "logging" {
  source = "../../modules/logging"
}

module "identity" {
  source = "../../modules/identity"
}

output "vpc_id" {
  description = "ID of the company VPC"
  value       = module.networking.vpc_id
}

output "public_subnet_id" {
  description = "ID of the public subnet"
  value       = module.networking.public_subnet_id
}

output "application_subnet_id" {
  description = "ID of the application subnet"
  value       = module.networking.application_subnet_id
}

output "database_subnet_id" {
  description = "ID of the database subnet"
  value       = module.networking.database_subnet_id
}

output "networking_public_security_group_id" {
  description = "ID of the public-tier security group"
  value       = module.networking.public_security_group_id
}

output "networking_application_security_group_id" {
  description = "ID of the application-tier security group"
  value       = module.networking.application_security_group_id
}

output "networking_database_security_group_id" {
  description = "ID of the database-tier security group"
  value       = module.networking.database_security_group_id
}

output "logs_bucket_name" {
  description = "Name of the security logging bucket"
  value       = module.logging.logs_bucket_name
}

output "logs_bucket_arn" {
  description = "ARN of the security logging bucket"
  value       = module.logging.logs_bucket_arn
}

