# Enterprise Security Infrastructure Lab

## Background
This project takes inspiration from one of the IT security internships I participated in during summer of 2026. While not an exact 1:1 copy, it takes a lot of aspects of real world and business class terraform infrastructure I came across working with the security engineering team.

## Project Overview
The project models a simplified enterprise infrastructure environment. I modeled it based on a hypothetical company comprising on approximately 100 employees working in an environment consisting of Windows workstations, Active Directory, corporate networking, firewalls, and cloud-hosted applications. 

The goal of the project was to demonstrate that aspects such as:

Infrastructure as Code using Terraform
Network segmentation
Least-privilege IAM
Security group design
Encrypted storage
Centralized security logging
Separation of administrative and application access
Automated infrastructure security testing
CI/CD security validation

Can be built and deployed on localized hardware, without paying out of pocket for an AWS subscription.

## The Architecture 
The environment is divided into three network tiers: Public Tier, Application Tier, and Database Tier, with the terraform network being represented by a VPC containing the different subnets. These subnets provide the security segmentation needed for a secure environment:

Public tier takes in internet-facing resources and only allows https from the internet.
Application tier takes in application workloads and allows https from public tier.
Database tier provides data storage and only allows PostgreSQL from application tier.

The Docker environment mirrors this architecture using these separate Docker networks:
company-public
company-application
company-database

## Identity and Access Management
IAM follows the principle of least privilege, with the environment modeling an application role titled company-application-role. This role is currently permitted to access only the applications designated S3 bucket. 

## Data Protection
by design, the security logging bucket uses:
Server-side encryption
AES-256 encryption
S3 versioning

## Logging and Monitoring
The environment also includes a dedicated security logging bucket titled company-security-logs. The bucket is configured for centralized security-related storage. Due to the fact that we are using LocalStack for this project, you wouldn't necessary need the increased security as if we were instead using a production AWS account. 

## Why LocalStack?
LocalStack was built for simulating cloud environments on own hardware and infrastructure to validate security, quality, and reliability faster and more efficiently. For this project, I wanted to avoid the route of paying for any AWS subscription if it wasn't needed. LocalStack can emulate AWS services locally, allowing terraform to interact with it without creating actual AWS resources. AWS even has documentation describing testing infrastructure with LocalStack and Terraform.
If interested, the documentation can be found here: https://docs.aws.amazon.com/prescriptive-guidance/latest/patterns/test-aws-infra-localstack-terraform.html 

## Automated Security Validation and CI/CD.
There are several implemented security-focused tests used in the environment. Such tests include:

- Terraform security tests, which validate Terraforms configuration and plan, VPC architecture, existence of network tiers, and absence of an Internet Gateway and NAT Gateway

-  IAM least-privilege tests, which validate application IAM role exists, expected policy is attached, required S3 permissions exist, and that there are no unrestricted S3 permissions.

- Logging security tests, which validates that security logging bucket exists, versioning is enabled, and erver-side encryption is configured. 

- Network segmentation tests, which validates if the public web service is reachable, application tier is isolated from the public network, database tier is isolated from the public network, and expected application/database communication exists.

With CI/CD, GitHub Actions automatically validates the infrastructure whenever changes are pushed or a pull request is created. The pipeline is as follows:

Git push / pull request --> terraform plan --> LocalStack --> terraform apply --> docker services --> the three tiers

One change that causes one test to fail, causes the whole workflow to fail.  

## Running the lab

- To run the lab, you must have the following prerequisites: Docker, Terraform, AWS CLI, LocalStack, and jq.

- Configure the environment variables: 'cp .env.example .env.'
- Set the required LocalStack authentication token in .env.

- Start LocalStack: 'docker compose up -d'
- Deploy infrastructure: 
'''cd infrastructure/local
terraform init
terraform plan
terraform apply'''

- Start application services:
'''cd ../../services
docker compose up -d'''

- Run the security tests from the project root:
'''bash tests/terraform_security.sh
bash tests/iam_least_privilege.sh
bash tests/logging_security.sh
bash tests/network_segmentation.sh'''
