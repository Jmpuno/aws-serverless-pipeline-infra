resource "aws_s3_bucket" "file_bucket" {
    bucket = "${var.project_name}-${var.environment}-file-bucket-${var.aws_account_id}"

    tags = {
        Project = var.project_name
        Environment = var.environment
    }


}