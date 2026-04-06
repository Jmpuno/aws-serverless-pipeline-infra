output "dynamodb_table_arn" {
    description = "ARN for our dynamo db"
    value       = aws_dynamodb_table.pipeline_db_table.arn
}

output "dynamodb_table_name" {
    description = "table name in our dynamo db"
    value       = aws_dynamodb_table.pipeline_db_table.name
}