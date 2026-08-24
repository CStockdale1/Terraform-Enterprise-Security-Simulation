#!/bin/bash

set -e

echo "Company Security Lab Logging Security Tests"
echo

AWS_ENDPOINT="http://localhost:4566"
LOG_BUCKET="company-security-logs"

export AWS_ACCESS_KEY_ID=test
export AWS_SECRET_ACCESS_KEY=test
export AWS_DEFAULT_REGION=us-east-1

echo "Checking centralized logging bucket..."

if aws --endpoint-url="$AWS_ENDPOINT" \
    s3api head-bucket \
    --bucket "$LOG_BUCKET" >/dev/null 2>&1; then
    echo "PASS: Centralized logging bucket exists."
else
    echo "FAIL: Centralized logging bucket does not exist."
    exit 1
fi

echo
echo "Checking log bucket versioning..."

VERSIONING=$(aws --endpoint-url="$AWS_ENDPOINT" \
    s3api get-bucket-versioning \
    --bucket "$LOG_BUCKET" \
    --query 'Status' \
    --output text)

if [[ "$VERSIONING" == "Enabled" ]]; then
    echo "PASS: Log bucket versioning is enabled."
else
    echo "FAIL: Log bucket versioning is not enabled."
    exit 1
fi

echo
echo "Checking log bucket encryption..."

ENCRYPTION=$(aws --endpoint-url="$AWS_ENDPOINT" \
    s3api get-bucket-encryption \
    --bucket "$LOG_BUCKET")

SSE_ALGORITHM=$(echo "$ENCRYPTION" | jq -r '
    .ServerSideEncryptionConfiguration.Rules[0]
    .ApplyServerSideEncryptionByDefault.SSEAlgorithm
')

if [[ "$SSE_ALGORITHM" == "AES256" ]]; then
    echo "PASS: Log bucket uses AES256 server-side encryption."
else
    echo "FAIL: Log bucket encryption is not configured as expected."
    exit 1
fi

echo
echo "Checking for unencrypted logging configuration..."

if [[ "$SSE_ALGORITHM" == "AES256" ]]; then
    echo "PASS: Centralized logging storage is encrypted at rest."
else
    echo "FAIL: Centralized logging storage is not encrypted."
    exit 1
fi

echo
echo "All logging security tests passed."