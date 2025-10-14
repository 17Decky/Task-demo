variable "aws_account_id" {
  description = "The AWS Account ID"
  type        = string
}

variable "github_username" {
  description = "GitHub Username"
  type        = string
}

variable "repository_names" {
  description = "List of names of the GitHub repository that will be allowed to assume the role."
  type        = list(string)
}

variable "role_name" {
  description = "Name of the IAM Role"
  type        = string
  default     = "GitHubActionsRole"
}
