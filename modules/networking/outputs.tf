output "vpc_id" {
  description = "ID of the company VPC"
  value       = aws_vpc.main.id
}

output "vpc_cidr" {
  description = "CIDR block of the company VPC"
  value       = aws_vpc.main.cidr_block
}

output "public_subnet_id" {
  description = "ID of the public subnet"
  value       = aws_subnet.public.id
}

output "application_subnet_id" {
  description = "ID of the application subnet"
  value       = aws_subnet.application.id
}

output "database_subnet_id" {
  description = "ID of the database subnet"
  value       = aws_subnet.database.id
}

output "public_security_group_id" {
  description = "ID of the public-tier security group"
  value       = aws_security_group.public.id
}

output "application_security_group_id" {
  description = "ID of the application-tier security group"
  value       = aws_security_group.application.id
}

output "database_security_group_id" {
  description = "ID of the database-tier security group"
  value       = aws_security_group.database.id
}
