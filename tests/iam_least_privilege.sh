#!/bin/bash

set -e

echo "Company Security Lab IAM Least-Privilege Tests"
echo

AWS_ENDPOINT="http://localhost:4566"
ROLE_NAME="company-application-role"
POLICY_NAME="company-application-storage-policy"
POLICY_ARN="arn:aws:iam::000000000000:policy/${POLICY_NAME}"

export AWS_ACCESS_KEY_ID=test
export AWS_SECRET_ACCESS_KEY=test
export AWS_DEFAULT_REGION=us-east-1

echo "Checking application IAM role..."

ROLE=$(aws --endpoint-url="$AWS_ENDPOINT" \
    iam get-role \
    --role-name "$ROLE_NAME")

if [[ "$(echo "$ROLE" | jq -r '.Role.RoleName')" == "$ROLE_NAME" ]]; then
    echo "PASS: Application IAM role exists."
else
    echo "FAIL: Application IAM role does not exist."
    exit 1
fi

echo
echo "Checking attached policies..."

ATTACHED_POLICIES=$(aws --endpoint-url="$AWS_ENDPOINT" \
    iam list-attached-role-policies \
    --role-name "$ROLE_NAME")

POLICY_COUNT=$(echo "$ATTACHED_POLICIES" | jq '.AttachedPolicies | length')

if [[ "$POLICY_COUNT" -eq 1 ]] && \
   [[ "$(echo "$ATTACHED_POLICIES" | jq -r '.AttachedPolicies[0].PolicyName')" == "$POLICY_NAME" ]]; then
    echo "PASS: Only the expected application storage policy is attached."
else
    echo "FAIL: Unexpected IAM policies are attached."
    exit 1
fi

echo
echo "Retrieving policy version..."

POLICY_VERSION=$(aws --endpoint-url="$AWS_ENDPOINT" \
    iam get-policy \
    --policy-arn "$POLICY_ARN" \
    --query 'Policy.DefaultVersionId' \
    --output text)

POLICY_DOCUMENT=$(aws --endpoint-url="$AWS_ENDPOINT" \
    iam get-policy-version \
    --policy-arn "$POLICY_ARN" \
    --version-id "$POLICY_VERSION")

echo "Checking policy permissions..."

ACTIONS=$(echo "$POLICY_DOCUMENT" | jq -r '
    .PolicyVersion.Document.Statement[]
    | select(.Effect == "Allow")
    | .Action
    | if type == "array" then .[] else . end
')

ACTION_COUNT=$(echo "$ACTIONS" | wc -l)

if [[ "$ACTION_COUNT" -eq 2 ]] && \
   echo "$ACTIONS" | grep -qx "s3:GetObject" && \
   echo "$ACTIONS" | grep -qx "s3:PutObject"; then
    echo "PASS: Policy grants exactly GetObject and PutObject."
else
    echo "FAIL: Policy contains unexpected or missing S3 permissions."
    echo
    echo "Detected actions:"
    echo "$ACTIONS"
    exit 1
fi

echo
echo "Checking for wildcard actions..."

WILDCARD_ACTIONS=$(echo "$ACTIONS" | grep -E '^\*$|^s3:\*$' || true)

if [[ -z "$WILDCARD_ACTIONS" ]]; then
    echo "PASS: Policy contains no wildcard actions."
else
    echo "FAIL: Policy contains wildcard actions."
    exit 1
fi

echo
echo "Checking resource scope..."

RESOURCES=$(echo "$POLICY_DOCUMENT" | jq -r '
    .PolicyVersion.Document.Statement[]
    | select(.Effect == "Allow")
    | .Resource
    | if type == "array" then .[] else . end
')

EXPECTED_RESOURCE="arn:aws:s3:::enterprise-security-lab-test/*"

if [[ "$(echo "$RESOURCES" | wc -l)" -eq 1 ]] && \
   [[ "$RESOURCES" == "$EXPECTED_RESOURCE" ]]; then
    echo "PASS: Policy is restricted to the application bucket."
else
    echo "FAIL: Policy contains unexpected resource scope."
    echo
    echo "Detected resources:"
    echo "$RESOURCES"
    exit 1
fi

echo
echo "Checking for wildcard resources..."

WILDCARD_RESOURCES=$(echo "$RESOURCES" | grep -E '^\*$' || true)

if [[ -z "$WILDCARD_RESOURCES" ]]; then
    echo "PASS: Policy does not grant wildcard resource access."
else
    echo "FAIL: Policy grants wildcard resource access."
    exit 1
fi

echo
echo "All IAM least-privilege tests passed."
