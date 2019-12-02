locals {
  project_name        = "aws-rails-example"
  state_bucket_name   = "aws-rails-example-terraform-state"
  state_dynamo_name   = "aws-rails-example-terraform-state"
  github_organization = "alex-bezek"
  github_repository   = "aws-ci-cd-example"
  github_branch       = "ci-cd-setup"
  ruby_version        = "2.6.5"
  domain_name = "alexbezek.me"
}

provider "aws" {
  region  = "us-west-2"
  profile = "default"
  version = "~> 2.40"
}

provider "archive" {
  version = "~> 1.3"
}

terraform {
  required_version = "~> 0.12.0"
  backend "s3" {
    bucket  = "aws-rails-example-terraform-state"
    key     = "terraform.tfstate"
    region  = "us-west-2"
    profile = "default"
    encrypt = true
  }
}
