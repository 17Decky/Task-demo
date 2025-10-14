provider "aws" {
  alias  = "root"
  region = "ap-south-1"
  default_tags {
    tags = {
      ManagedBy = "Terraform"
    }
  }
}