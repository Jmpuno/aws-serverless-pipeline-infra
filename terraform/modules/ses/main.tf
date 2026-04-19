resource "aws_ses_email_identity" "admin_email" {
    email = var.admin_email
}