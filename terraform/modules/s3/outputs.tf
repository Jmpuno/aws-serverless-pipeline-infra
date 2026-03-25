output "bucket_arn"{
    description = "Our s3 bucket arn"
    value = aws_s3_bucket.file_bucket.arn
}

output "bucket_name"{
    description = "Our s3 bucket name"
    value = aws_s3_bucket.file_bucket.bucket
}