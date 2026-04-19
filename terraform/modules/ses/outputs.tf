output "admin_email_identity_arn"{
    description = "admin ses email identity arn"
    value = aws_ses_email_identity.admin_email.arn
}