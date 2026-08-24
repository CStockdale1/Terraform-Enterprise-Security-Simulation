resource "aws_security_group" "public" {
  name        = "company-public-sg"
  description = "Security group for public-facing resources"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "company-public-sg"
    Tier = "public"
  }
}

resource "aws_security_group" "application" {
  name        = "company-application-sg"
  description = "Security group for application resources"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "company-application-sg"
    Tier = "application"
  }
}

resource "aws_security_group" "database" {
  name        = "company-database-sg"
  description = "Security group for database resources"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "company-database-sg"
    Tier = "database"
  }
}

resource "aws_vpc_security_group_ingress_rule" "public_https" {
  security_group_id = aws_security_group.public.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 443
  to_port     = 443
  ip_protocol = "tcp"

  description = "Allow HTTPS from the Internet"
}

resource "aws_vpc_security_group_ingress_rule" "application_https" {
  security_group_id = aws_security_group.application.id

  referenced_security_group_id = aws_security_group.public.id
  from_port                    = 443
  to_port                      = 443
  ip_protocol                  = "tcp"

  description = "Allow HTTPS from public-facing resources"
}

resource "aws_vpc_security_group_ingress_rule" "database_postgresql" {
  security_group_id = aws_security_group.database.id

  referenced_security_group_id = aws_security_group.application.id
  from_port                    = 5432
  to_port                      = 5432
  ip_protocol                  = "tcp"

  description = "Allow PostgreSQL from application resources"
}
