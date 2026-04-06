resource "aws_dynamodb_table" "pipeline_db_table"{
    name = "${var.project_name}-${var.environment}-pipeline-db-table"
    billing_mode = "PAY_PER_REQUEST"
    hash_key = "FileID"

    attribute {
        name = "FileID"
        type = "S"
    }

    tags = {
        Name = "pipeline-db-table"
    }
}