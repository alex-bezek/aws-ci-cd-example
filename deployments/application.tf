# create a zip of your deployment with terraform
data "archive_file" "artifact_zip" {
  type        = "zip"
  source_dir = "../"
  output_path = "../tmp/artifact.zip"
}

resource "aws_s3_bucket_object" "artifact" {
  key    = "application-${uuid()}"
  bucket = aws_s3_bucket.artifacts.id
  source = data.archive_file.artifact_zip.output_path
}

resource "aws_elastic_beanstalk_application_version" "version" {
  name        = "aws-rails-example-${uuid()}"
  application = aws_elastic_beanstalk_application.app.name
  description = "application version created by terraform"
  bucket      = aws_s3_bucket.artifacts.id
  key         = aws_s3_bucket_object.artifact.id
}

resource "aws_s3_bucket" "artifacts" {
  bucket = "aws-rails-example-artifacts"
  acl = "private"
}

resource "aws_elastic_beanstalk_application" "app" {
  name        = "aws-rails-example-name"
  description = "aws-rails-example-desc"

  # appversion_lifecycle {
  #   service_role          = aws_iam_role.beanstalk_service.arn
  #   max_count             = 128
  #   max_age_in_days = 30
  #   delete_source_from_s3 = true
  # }
}

resource "aws_elastic_beanstalk_configuration_template" "template" {
  name                = "aws-rails-example-template-config"
  application         = aws_elastic_beanstalk_application.app.name
  solution_stack_name = "64bit Amazon Linux 2018.03 v2.11.1 running Ruby 2.6 (Passenger Standalone)"
}


resource "aws_elastic_beanstalk_environment" "prod" {
  name                = "aws-rails-example-name"
  application         = aws_elastic_beanstalk_application.app.name
  solution_stack_name = "64bit Amazon Linux 2018.03 v2.11.1 running Ruby 2.6 (Passenger Standalone)"

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name = "IamInstanceProfile"
    value = aws_iam_instance_profile.build.name
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name = "RAILS_SKIP_ASSET_COMPILATION"
    value = "true"
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name = "RAILS_SKIP_MIGRATIONS"
    value = "true"
  }
}

output "url" {
  value = aws_elastic_beanstalk_environment.prod.cname
}
output "env_name" {
  value = "${aws_elastic_beanstalk_environment.prod.name}"
}
output "app_version" {
  value = "${aws_elastic_beanstalk_application_version.version.name}"
}

# aws --region us-west-2 elasticbeanstalk update-environment --environment-name $(terraform output env_name) --version-label $(terraform output app_version)