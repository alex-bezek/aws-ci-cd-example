variable "github_oauth_token" {
  type        = string
  description = "Github oauth access token for code build to use"
}

variable "rails_master_key" {
  type        = string
  description = "The rails master credentials key for decoding secrets"
}
