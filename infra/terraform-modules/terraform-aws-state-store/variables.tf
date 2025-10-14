# variables.tf

variable "state_bucket_tags" {
  description = "Tags to set on the state bucket."
  type        = map(string)
  default     = {}
}

variable "state_dynamodb_tags" {
  description = "Tags to set on the state dynamodb."
  type        = map(string)
  default     = {}
}

variable "aws_infra_terraform_bucket" {
  type = string
  default = ""
  description = "terraform bucket state store on S3"
}

variable "aws_infra_terraform_bucket_kms_key_id" {
  type = string
  default = ""
  description = "kms key for state bucket encryption"
}

variable "aws_infra_terraform_dynamodb_table" {
  type = string
  default = ""
  description = "dynamodb for state storage"
}

