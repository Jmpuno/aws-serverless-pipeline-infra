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
