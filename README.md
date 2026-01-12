# Cloud Resume Project using AWS 

This project is a cloud hosted resume built to demonstrate hands on experience with AWS, Infrastructure as Code, and CI/CD practices.  
Instead of hosting a resume locally or as a PDF, the site is deployed using real cloud services with a focus on security and cost awareness.

---

## What this project does

- Hosts a static resume website on AWS
- Uses CloudFront to deliver the site securely over HTTPS
- Keeps the S3 bucket private and accessible only through CloudFront
- Implements a serverless visitor counter
- Automates deployments using GitHub Actions
- Provisions infrastructure using Terraform

The goal of this project is to show practical cloud knowledge, not just theory.

---

## Architecture Overview

- **Amazon S3**  
  Stores the static website files (`index.html`, `style.css`). Public access is blocked.

- **Amazon CloudFront**  
  Acts as a CDN and HTTPS entry point. CloudFront is the only service allowed to read from the S3 bucket.

- **AWS Lambda**  
  A lightweight Python function increments and returns the visitor count.

- **Amazon DynamoDB**  
  Stores the visitor count using a simple key-value structure.

- **IAM**  
  Least privilege roles and policies are used for Lambda and CI/CD access.

- **Terraform**  
  Infrastructure is defined and managed using Infrastructure as Code.

- **GitHub Actions**  
  Automatically deploys website updates to S3 on every push.

---

## CI/CD Flow

1. Code is pushed to the repository
2. GitHub Actions authenticates to AWS using OIDC (no access keys stored)
3. Static files are synced to the S3 bucket
4. CloudFront cache is invalidated so updates are visible immediately

---

## Visitor Counter Logic

1. The resume page loads in the browser
2. JavaScript calls a public Lambda Function URL
3. Lambda reads the current count from DynamoDB
4. The count is incremented and written back
5. The updated value is returned and displayed on the page

---

## Cost Considerations

- The project is designed to stay within AWS Free Tier for normal resume traffic
- No EC2, NAT Gateway, or paid networking services are used
- Resources can be destroyed and recreated at any time using Terraform
- Cloud resources were removed after demonstration to avoid unnecessary costs

---

## Why I built this

I wanted a project that demonstrates:
- Real AWS services working together
- Secure access patterns (private S3 + CloudFront)
- Automation using CI/CD

This project helped me better understand how cloud infrastructure, security, and automation fit together in a real world setup.

## Architecture
```
┌─────────────┐
│ User Browser│
└──────┬──────┘
       │
       ├─── HTTPS ────► CloudFront ────OAC────► S3 Bucket
       │                                         (HTML, CSS)
       │
       └─── Fetch ────► Lambda ────Read/Write──► DynamoDB
            Count        Function                 (Visitor Count)
```

**Flow:**
1. User requests resume → CloudFront serves static files from private S3
2. JavaScript fetches visitor count → Lambda Function URL (HTTPS)
3. Lambda increments count → DynamoDB stores the value
4. Count displayed on resume page

**Infrastructure:** Terraform manages S3, CloudFront, Lambda, DynamoDB, IAM roles

                                               
Last updated: January 2026 , 3:59pm EST 1/12/2026 .