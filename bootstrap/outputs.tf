output "state_bucket" {
  value = aws_s3_bucket.tf_state.bucket
}

output "lock_table" {
  value = aws_dynamodb_table.tf_locks.name
}

output "github_actions_role_arn" {
  value = aws_iam_role.github_actions.arn
}
