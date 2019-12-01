locals {
  state_bucket_name = "aws-rails-example-terraform-state"
  state_dynamo_name = "aws-rails-example-terraform-state"
  github_organization = "alex-bezek"
  github_repository = "aws-ci-cd-example"
  github_branch = "ci-cd-setup"
}

variable "github_oauth_token" {
  type        = string
  description = "Github oauth access token for code build to use"
}

variable "rails_master_key" {
  type        = string
  description = "The rails master credentials key for decoding secrets"
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
