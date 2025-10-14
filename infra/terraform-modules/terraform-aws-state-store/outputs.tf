# outputs.tf

output "state_bucket_arn" {
  description = "aws infra terraform state bucket arn"
  value = aws_s3_bucket.aws_infra_terraform_bucket.arn
}

output "state_bucket_id" {
  description = "aws infra terraform state bucket id"
  value = aws_s3_bucket.aws_infra_terraform_bucket.id
}

output "state_dynamodb_arn" {
  description = "aws infra state dynamodb table arn"
  value = aws_dynamodb_table.aws_infra_terraform_dynamodb_table.arn
}

output "state_dynamodb_id" {
  description = "aws infra state dynamodb table arn"
  value = aws_dynamodb_table.aws_infra_terraform_dynamodb_table.id
}
