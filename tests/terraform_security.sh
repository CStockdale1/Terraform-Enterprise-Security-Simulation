#!/bin/bash

set -e

echo "Company Security Lab Terraform Security Tests"
echo

echo "Checking Terraform configuration..."

terraform -chdir=infrastructure/local validate

echo "PASS: Terraform configuration is valid."

echo
echo "Checking Terraform plan..."

PLAN_OUTPUT=$(terraform -chdir=infrastructure/local plan -no-color)

if echo "$PLAN_OUTPUT" | grep -q "No changes"; then
    echo "PASS: Terraform infrastructure is up to date."
else
    echo "INFO: Terraform plan contains changes."
fi

echo
echo "Checking network architecture..."

VPC_ID=$(terraform -chdir=infrastructure/local output -raw vpc_id)
PUBLIC_SUBNET=$(terraform -chdir=infrastructure/local output -raw public_subnet_id)
APPLICATION_SUBNET=$(terraform -chdir=infrastructure/local output -raw application_subnet_id)
DATABASE_SUBNET=$(terraform -chdir=infrastructure/local output -raw database_subnet_id)

if [[ -n "$VPC_ID" ]] && \
   [[ -n "$PUBLIC_SUBNET" ]] && \
   [[ -n "$APPLICATION_SUBNET" ]] && \
   [[ -n "$DATABASE_SUBNET" ]]; then
    echo "PASS: VPC and all three network tiers exist."
else
    echo "FAIL: Required network resources are missing."
    exit 1
fi

echo
echo "Checking for Internet Gateway..."

IGW_COUNT=$(AWS_ACCESS_KEY_ID=test AWS_SECRET_ACCESS_KEY=test \
    aws --endpoint-url=http://localhost:4566 \
    ec2 describe-internet-gateways \
    --query 'length(InternetGateways)' \
    --output text)

if [[ "$IGW_COUNT" == "0" ]]; then
    echo "PASS: No Internet Gateway exists."
else
    echo "FAIL: Internet Gateway detected."
    exit 1
fi

echo
echo "Checking for NAT Gateway..."

NAT_COUNT=$(AWS_ACCESS_KEY_ID=test AWS_SECRET_ACCESS_KEY=test \
    aws --endpoint-url=http://localhost:4566 \
    ec2 describe-nat-gateways \
    --query 'length(NatGateways)' \
    --output text)

if [[ "$NAT_COUNT" == "0" ]]; then
    echo "PASS: No NAT Gateway exists."
else
    echo "FAIL: NAT Gateway detected."
    exit 1
fi

echo
echo "Checking security group configuration..."

PUBLIC_SG=$(terraform -chdir=infrastructure/local output -raw networking_public_security_group_id)
APPLICATION_SG=$(terraform -chdir=infrastructure/local output -raw networking_application_security_group_id)
DATABASE_SG=$(terraform -chdir=infrastructure/local output -raw networking_database_security_group_id)

if [[ -n "$PUBLIC_SG" ]] && \
   [[ -n "$APPLICATION_SG" ]] && \
   [[ -n "$DATABASE_SG" ]]; then
    echo "PASS: Required security groups exist."
else
    echo "FAIL: Required security groups are missing."
    exit 1
fi

echo
echo "Checking database security group..."

DB_RULE=$(AWS_ACCESS_KEY_ID=test AWS_SECRET_ACCESS_KEY=test \
    aws --endpoint-url=http://localhost:4566 \
    ec2 describe-security-groups \
    --group-ids "$DATABASE_SG" \
    --query 'SecurityGroups[0].IpPermissions[?FromPort==`5432` && ToPort==`5432` && UserIdGroupPairs[0].GroupId==`'"$APPLICATION_SG"'`]' \
    --output text)

if [[ -n "$DB_RULE" ]]; then
    echo "PASS: Database accepts PostgreSQL only from application security group."
else
    echo "FAIL: Database security group rule is incorrect."
    exit 1
fi

echo
echo "Checking security logging bucket..."

LOGS_BUCKET=$(terraform -chdir=infrastructure/local output -raw logs_bucket_name)

if [[ -n "$LOGS_BUCKET" ]]; then
    echo "PASS: Security logging bucket exists."
else
    echo "FAIL: Security logging bucket output is missing."
    exit 1
fi

echo
echo "Checking logging bucket versioning..."

VERSIONING_STATUS=$(AWS_ACCESS_KEY_ID=test AWS_SECRET_ACCESS_KEY=test \
    aws --endpoint-url=http://localhost:4566 \
    s3api get-bucket-versioning \
    --bucket "$LOGS_BUCKET" \
    --query 'Status' \
    --output text)

if [[ "$VERSIONING_STATUS" == "Enabled" ]]; then
    echo "PASS: Logging bucket versioning is enabled."
else
    echo "FAIL: Logging bucket versioning is not enabled."
    exit 1
fi

echo
echo "Checking logging bucket encryption..."

ENCRYPTION_ALGORITHM=$(AWS_ACCESS_KEY_ID=test AWS_SECRET_ACCESS_KEY=test \
    aws --endpoint-url=http://localhost:4566 \
    s3api get-bucket-encryption \
    --bucket "$LOGS_BUCKET" \
    --query 'ServerSideEncryptionConfiguration.Rules[0].ApplyServerSideEncryptionByDefault.SSEAlgorithm' \
    --output text)

if [[ "$ENCRYPTION_ALGORITHM" == "AES256" ]]; then
    echo "PASS: Logging bucket encryption is enabled with AES-256."
else
    echo "FAIL: Logging bucket encryption is not configured correctly."
    exit 1
fi

echo
echo "Terraform security tests completed."
