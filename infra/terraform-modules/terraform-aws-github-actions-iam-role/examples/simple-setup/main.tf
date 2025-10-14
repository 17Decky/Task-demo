module "github_actions_iam_role" {
  source           = "github.com/infraspecdev/terraform-aws-github-actions-iam-role?ref=main"
  aws_account_id   = var.aws_account_id
  github_username  = var.github_username
  repository_names = var.repository_names
  role_name        = var.role_name
  providers = {
    aws = aws.root
  }
}
