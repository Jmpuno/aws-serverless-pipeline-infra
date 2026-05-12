# aws-serverless-pipeline-infra

A production-grade, serverless file processing pipeline built on AWS — fully provisioned with Terraform. Upload a file, and the pipeline automatically validates, processes, stores results, and notifies stakeholders. No servers to manage. No manual steps.

> **Focus:** Infrastructure engineering — reliability, security, observability, scalability, and repeatability over business logic complexity.

---

## Architecture Overview

```
User (Netlify Frontend)
        │
        ▼
Lambda Function URL ──► Lambda (URL Generator) ──► S3 Presigned POST URL
                                                            │
                                                            ▼
                                                      S3 Bucket (Upload)
                                                            │
                                                    S3 Event Notification
                                                            │
                                                            ▼
                                               Lambda (Trigger) ──► Lambda-level DLQ
                                                            │
                                                            ▼
                                                       SQS Queue ──► SQS DLQ
                                                            │
                                                            ▼
                                               Lambda (Worker) ──► DynamoDB
                                                            │
                                                            ├──► SNS (Admin Email)
                                                            └──► SES (User Email)
                                                            │
                                                       CloudWatch (All logs)
```

---

## Services Used

| Service | Role |
|---|---|
| **S3** | File storage — upload destination, globally unique bucket name |
| **Lambda (Trigger)** | Detects S3 upload events, forwards metadata to SQS |
| **Lambda (Worker)** | Processes file, saves to DynamoDB, sends notifications |
| **Lambda (URL Generator)** | Generates S3 presigned POST URL for secure frontend uploads |
| **Lambda Function URL** | Exposes URL generator publicly — no API Gateway needed |
| **SQS** | Buffers processing jobs — handles burst uploads without overwhelming worker |
| **SQS DLQ** | Isolates failed SQS messages for debugging |
| **Lambda DLQ** | Isolates failed async Lambda invocations |
| **DynamoDB** | Stores processing results — PAY_PER_REQUEST billing |
| **SNS** | Broadcasts admin notification on file processing completion |
| **SES** | Sends email notification to the file uploader |
| **CloudWatch** | Centralized logging for all Lambda functions — 30-day retention |
| **IAM** | Least-privilege roles and policies per Lambda function |

---

## Key Architecture Decisions

### No VPC
All services are AWS-managed public endpoints secured via IAM. Adding a VPC would introduce unnecessary complexity without sufficient justification at this stage.

**When to revisit:** When the architecture includes a frontend load balancer, private RDS/ElastiCache instances, or EC2/ECS workloads requiring subnet isolation.

### Lambda Function URL over API Gateway
Only one function needs HTTP exposure — the presigned URL generator. API Gateway would add complexity and cost without benefit for a single-function use case.

**When to revisit:** When multiple HTTP endpoints, VPC integration, or complex auth (Cognito, JWT) are required.

### SQS as Buffer
Direct S3-to-Lambda-worker chaining would risk overwhelming the worker during burst uploads. SQS decouples ingestion from processing, enables retry logic, and provides a dead-letter queue for failed messages.

### DynamoDB over RDS
Access pattern is simple key-value: store by FileID, retrieve by FileID. No joins or complex queries required. DynamoDB provides single-digit millisecond latency with no server management.

**When to revisit:** When reporting queries, joins, or complex aggregations are needed — consider adding an analytics layer (Athena/Redshift) rather than replacing DynamoDB.

### Iterative Least Privilege IAM
Policies were built iteratively — deploy first with no permissions, observe exact errors in CloudWatch, add only the required action on the specific resource. No wildcards on resource ARNs.

### PAY_PER_REQUEST for DynamoDB
Upload volume is unpredictable. On-demand billing avoids over-provisioning costs and auto-scales without capacity planning.

### 30-Day CloudWatch Log Retention
Balance between 7-day (cheapest, good for dev debugging) and 90-day (industry standard for security logs). 30 days is sufficient for monthly reporting and post-incident investigations at a reasonable cost.

---

## Project Structure

```
aws-serverless-pipeline-infra/
│
├── docs/
│   └── architecture.md          # Architecture decision log
│
├── src/
│   ├── lambda_s3_url_generator/
│   │   └── lambda_s3_url_generator.py
│   ├── trigger_lambda/
│   │   └── trigger_lambda.py
│   └── lambda_worker/
│       └── lambda_worker.py
│
└── terraform/
    ├── main.tf                  # Root module — connects all modules
    ├── variables.tf             # Root variable definitions
    ├── outputs.tf               # Root outputs
    ├── environments/
    │   └── dev/
    │       └── dev.tfvars       # Dev environment values (gitignored)
    └── modules/
        ├── s3/                  # S3 bucket + CORS + event notification
        ├── lambda/              # Trigger + Worker Lambda functions
        ├── lambda_frontend/     # URL Generator + Lambda Function URL
        ├── iam/                 # Roles and policies per function
        ├── sqs/                 # Main queue + DLQ
        ├── sns/                 # Topic + admin email subscription
        ├── ses/                 # Admin email identity verification
        ├── dynamodb/            # Results table
        └── cloudwatch/          # Log groups per Lambda function
```

---

## IAM Permissions (Per Function)

### Trigger Lambda
- `logs:CreateLogStream`, `logs:PutLogEvents` → CloudWatch log group
- `s3:GetObject` → specific S3 bucket
- `sqs:SendMessage` → main SQS queue + Lambda DLQ

### Worker Lambda
- `logs:CreateLogStream`, `logs:PutLogEvents` → CloudWatch log group
- `s3:GetObject` → specific S3 bucket
- `sqs:ReceiveMessage`, `sqs:DeleteMessage`, `sqs:GetQueueAttributes` → main SQS queue
- `dynamodb:PutItem` → specific DynamoDB table
- `sns:Publish` → specific SNS topic
- `ses:SendEmail` → SES identity

### URL Generator Lambda
- `logs:CreateLogStream`, `logs:PutLogEvents` → CloudWatch log group
- `s3:PutObject` → specific S3 bucket

---

## Prerequisites

- AWS CLI configured (`aws configure`)
- Terraform >= 1.0
- Python 3.14 (for Lambda runtime)

---

## Deployment

```bash
# 1. Clone the repository
git clone https://github.com/Jmpuno/aws-serverless-pipeline-infra.git
cd aws-serverless-pipeline-infra/terraform

# 2. Create your tfvars file
cp environments/dev/dev.tfvars.example environments/dev/dev.tfvars
# Fill in your values

# 3. Initialize Terraform
terraform init

# 4. Preview the plan
terraform plan -var-file="environments/dev/dev.tfvars"

# 5. Deploy
terraform apply -var-file="environments/dev/dev.tfvars"
```

---

## Environment Variables (dev.tfvars)

```hcl
project_name = "serverless-pipeline"
environment  = "dev"
admin_email  = "your-email@example.com"
allowed_origin = "https://your-frontend.netlify.app"
log_level    = "DEBUG"
```

> **Note:** Never commit `dev.tfvars` — it contains sensitive values. It is gitignored by default.

---

## Testing

Upload a file via AWS CLI with metadata:

```bash
aws s3 cp test.csv \
  s3://<your-bucket>/uploads/user@email.com/test.csv \
  --metadata email=user@email.com
```

Then check:
- **CloudWatch** → `/aws/lambda/serverless-pipeline-dev-trigger-lambda` for trigger logs
- **CloudWatch** → `/aws/lambda/serverless-pipeline-dev-lambda-worker` for processing logs
- **DynamoDB** → `serverless-pipeline-dev-pipeline-db-table` for saved results
- **Gmail** → admin email notification from SES

---

## Future Improvements

- [ ] Request SES production access — remove sandbox limitation on recipient emails
- [ ] Add Terraform remote state (S3 backend + state locking)
- [ ] Add CloudWatch alarms for DLQ message count
- [ ] Add AWS X-Ray distributed tracing
- [ ] Add S3 lifecycle policies for automatic file archival
- [ ] CI/CD pipeline via GitHub Actions
- [ ] Add VPC when private resources are introduced

---

## Frontend

A vanilla HTML/CSS/JS file uploader is deployed on Netlify:

**Live:** [https://aws-severless-pipeline-file-uploader.netlify.app](https://aws-severless-pipeline-file-uploader.netlify.app)

Supported file types: CSV, JSON, PDF, JPEG, PNG, GIF, WebP, SVG

Max file size: 5MB per file

---

## Author

**Justine Matthew Puno** — Aspiring Cloud Engineer

Built as a hands-on learning project to develop real cloud engineering skills — infrastructure design, security, observability, and architectural decision-making.

> *"Every infrastructure decision in this project has a justification — not just a default value."*
