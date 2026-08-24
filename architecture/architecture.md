\# Infrastructure Security Lab



\## 1. Project Overview



We are representing a fictional organization with approximately

100 employees. Its environment consists of Windows workstations,

Active Directory, corporate networking, firewalls, and cloud-hosted

applications.



This project models a small portion of the companies cloud infrastructure

using Terraform and LocalStack.



The goal is to demonstrate infrastructure-as-code, network segmentation,

identity and access management, least privilege, logging, encryption,

and automated security validation.



No proprietary company information, configurations, credentials,

addresses, or infrastructure details are used.



\---



\## 2. Architecture Goals



The environment must provide:



\- Network segmentation between public, application, and database tiers.

\- Restricted communication between network tiers.

\- Least-privilege IAM permissions.

\- Private database infrastructure.

\- Encrypted storage.

\- Centralized logging.

\- Administrative access separated from application access.

\- Infrastructure deployed entirely through Terraform.

\- Automated validation through CI/CD.



\---



\## 3. Network Architecture



The environment will contain three logical tiers.



\### Public Tier



Contains resources that require controlled Internet-facing access.



Examples:



\- Load balancer

\- Public-facing application entry point



\### Application Tier



Contains application workloads.



Examples:



\- Application servers

\- Application-specific IAM roles



Application servers should accept traffic only from the

appropriate public-tier resources.



\### Database Tier



Contains data-storage infrastructure.



The database tier must not be directly accessible from the Internet.



Database access should only be permitted from authorized application

resources.



\---



\## 4. Identity and Access Management



IAM will follow the principle of least privilege.



Different identities and roles will have different permissions.



Examples:



\- Application role

\- Logging role

\- Security/auditing role

\- Administrative role



Application workloads should not receive unrestricted administrative

permissions.



\---



\## 5. Security Controls



The environment will implement:



\### Network Security



\- Security groups

\- Network segmentation

\- Restricted ingress

\- Restricted egress

\- No direct Internet access to private resources



\### Identity Security



\- Least-privilege IAM policies

\- Separation of administrative and application permissions

\- No unnecessary wildcard permissions



\### Data Security



\- Encryption at rest

\- Controlled access to storage

\- Private database resources



\### Monitoring



\- Centralized logging

\- Audit-oriented logs

\- Security-relevant events



\---



\## 6. Threat Model



The project will initially model several common infrastructure

security weaknesses.



Examples:



\- Publicly accessible database

\- Overly permissive security groups

\- Excessive IAM permissions

\- Unencrypted storage

\- Missing logging



These weaknesses will be documented and subsequently remediated.



\---



\## 7. Implementation Strategy



The environment will be implemented using:



\- Terraform

\- LocalStack

\- Docker

\- Git

\- GitHub Actions



All infrastructure should be reproducible from the Terraform

configuration.



The environment will be deployed locally without requiring

paid cloud infrastructure.



\---



\## 8. Validation



The project will validate:



\- Terraform configuration

\- Terraform plans

\- Resource deployment

\- Network security rules

\- IAM permissions

\- Encryption configuration

\- Logging configuration



Automated tests will eventually run through GitHub Actions.



