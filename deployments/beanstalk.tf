
locals {
  application_port    = 80 # Default for rails passenger setup
  solution_stack_name = "64bit Amazon Linux 2018.03 v2.11.1 running Ruby 2.6 (Passenger Standalone)"
}

# The aws bucket to store zip artifacts created by our code build for deployment to beanstalk
resource "aws_s3_bucket" "artifacts" {
  bucket = "${local.project_name}-artifacts"
  acl    = "private"
}

resource "aws_elastic_beanstalk_application" "app" {
  name        = "${local.project_name}"
  description = "${local.project_name}"

  # appversion_lifecycle {
  #   service_role          = aws_iam_role.beanstalk_service.arn # TODO: Determine what iam roles this needs
  #   max_count             = 128
  #   max_age_in_days       = 30
  #   delete_source_from_s3 = true
  # }
}

# Standard template based off the provided stack name to avoid having to pass in
# all the common settings for our deployment type
resource "aws_elastic_beanstalk_configuration_template" "template" {
  name                = "${local.project_name}-standard-template"
  application         = aws_elastic_beanstalk_application.app.name
  solution_stack_name = local.solution_stack_name
}

# Our production/primary hosted deployment. Currently the only deployed
# instance, but in the future, there would be multiple environmnemnts for promting changes
resource "aws_elastic_beanstalk_environment" "prod" {
  name                = "${local.project_name}"
  application         = aws_elastic_beanstalk_application.app.name
  solution_stack_name = local.solution_stack_name

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "IamInstanceProfile"
    value     = aws_iam_instance_profile.build.name
  }

  # Skip the asset compiliation. Currently this is done via code build, so the packs
  # are included in the zip file uploaded into s3. Building the assets on the elastic
  # beanstalk node had problems (i beleive it was due to yarn and node not being installed)
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "RAILS_SKIP_ASSET_COMPILATION"
    value     = "true"
  }

  # This is set to true by the default template. Default it to false until we have
  # and actual need for a database
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "RAILS_SKIP_MIGRATIONS"
    value     = "true"
  }

  # Rails master key needs injected via terraform variable. This value is secret
  # and is not checked into the primary repo.
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "RAILS_MASTER_KEY"
    value     = var.rails_master_key
  }

  //////////////////////////////
  ////// HTTPS SETTINGS ////////
  //////////////////////////////
  # http -> https redirect pending https://github.com/awsdocs/elastic-beanstalk-samples/tree/master/configuration-files/aws-provided/security-configuration/https-redirect/ruby-passenger/https-redirect-single-instance-ruby-passenger
  setting {
    namespace = "aws:elb:listener:443"
    name      = "ListenerProtocol"
    value     = "HTTPS"
  }

  setting {
    namespace = "aws:elb:listener:443"
    name      = "InstancePort"
    value     = local.application_port
  }

  setting {
    namespace = "aws:elb:listener:443"
    name      = "SSLCertificateId"
    value     = aws_acm_certificate.cert.arn
  }

  setting {
    namespace = "aws:elb:listener:443"
    name      = "ListenerEnabled"
    value     = "true"
  }
}
