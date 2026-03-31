## VPC Decision

**Decision:** No VPC for current setup.

**Reason:** All services (S3, Lambda, SQS, DynamoDB, SNS)
are AWS-managed public endpoints secured via IAM policies.
No private resources requiring network isolation exist
in the current architecture.

**When to revisit:** When the architecture includes:
- Frontend with public-facing load balancer
- Private RDS or ElastiCache instances
- EC2 or ECS workloads requiring private subnets
- Lambda functions needing access to private VPC resources

**Trade-off accepted:** No network-level isolation.
Mitigation: Strict IAM least-privilege policies per service.



## File Upload Approach

Decision: Lambda Function URL para sa presigned URL generation

Reason: Single function lang ang kailangan — 
API Gateway ay overkill para sa use case na ito.

When to revisit: Kapag kailangan na ng multiple 
endpoints, VPC integration, o complex auth.
