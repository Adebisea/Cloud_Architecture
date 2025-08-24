output "secret_arn" {
    value = aws_db_instance.db_techn.master_user_secret[0].secret_arn
}
