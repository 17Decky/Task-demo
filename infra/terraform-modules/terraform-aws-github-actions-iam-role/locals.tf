locals {
  repository_ref_list = flatten([
    for repo in var.repository_names :
    "repo:${var.github_username}/${repo}:*"

  ])
}
